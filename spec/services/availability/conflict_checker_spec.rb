require 'rails_helper'

RSpec.describe Availability::ConflictChecker do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-test') }
  let(:pro) { Professional.create!(account: account, name: 'Carlos', email: 'carlos@test.com') }
  let(:service) { Service.create!(account: account, name: 'Corte', duration_minutes: 30, price_cents: 4000) }
  let(:client) { Client.create!(account: account, name: 'João', email: 'joao@test.com') }

  before do
    ActsAsTenant.current_tenant = account
  end

  after do
    ActsAsTenant.current_tenant = nil
  end

  describe '#has_conflict?' do
    let(:base_time) { Time.zone.parse('2026-09-01 10:00:00') }

    context 'when there are no appointments or exceptions' do
      it 'returns false' do
        checker = described_class.new(
          professional: pro,
          starts_at: base_time,
          ends_at: base_time + 30.minutes
        )
        expect(checker.has_conflict?).to be false
      end
    end

    context 'when an active appointment exists in the same window' do
      before do
        Appointment.create!(
          account: account,
          professional: pro,
          service: service,
          client: client,
          starts_at: base_time,
          ends_at: base_time + 30.minutes,
          status: :confirmed
        )
      end

      it 'returns true for exact overlap' do
        checker = described_class.new(
          professional: pro,
          starts_at: base_time,
          ends_at: base_time + 30.minutes
        )
        expect(checker.has_conflict?).to be true
      end

      it 'returns true for partial overlap inside' do
        checker = described_class.new(
          professional: pro,
          starts_at: base_time + 10.minutes,
          ends_at: base_time + 20.minutes
        )
        expect(checker.has_conflict?).to be true
      end

      it 'returns true for partial overlap overlapping start' do
        checker = described_class.new(
          professional: pro,
          starts_at: base_time - 15.minutes,
          ends_at: base_time + 15.minutes
        )
        expect(checker.has_conflict?).to be true
      end

      it 'returns false when ignoring that specific appointment' do
        appointment = Appointment.last
        checker = described_class.new(
          professional: pro,
          starts_at: base_time,
          ends_at: base_time + 30.minutes,
          ignore_appointment_id: appointment.id
        )
        expect(checker.has_conflict?).to be false
      end

      it 'returns false for contiguous appointments (starts exactly when existing ends)' do
        checker = described_class.new(
          professional: pro,
          starts_at: base_time + 30.minutes,
          ends_at: base_time + 60.minutes
        )
        expect(checker.has_conflict?).to be false
      end
    end

    context 'when a cancelled appointment exists' do
      before do
        Appointment.create!(
          account: account,
          professional: pro,
          service: service,
          client: client,
          starts_at: base_time,
          ends_at: base_time + 30.minutes,
          status: :cancelled
        )
      end

      it 'returns false' do
        checker = described_class.new(
          professional: pro,
          starts_at: base_time,
          ends_at: base_time + 30.minutes
        )
        expect(checker.has_conflict?).to be false
      end
    end

    context 'when a blocked schedule exception exists for that day' do
      before do
        ScheduleException.create!(
          professional: pro,
          exception_date: base_time.to_date,
          is_blocked: true,
          reason: 'Feriado'
        )
      end

      it 'returns true' do
        checker = described_class.new(
          professional: pro,
          starts_at: base_time,
          ends_at: base_time + 30.minutes
        )
        expect(checker.has_conflict?).to be true
      end
    end
  end
end
