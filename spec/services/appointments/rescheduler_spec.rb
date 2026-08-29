# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Appointments::Rescheduler do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-rescheduler-test') }
  let(:pro) { Professional.create!(account: account, name: 'Carlos', email: 'carlos@test.com') }
  let(:service) { Service.create!(account: account, name: 'Corte', duration_minutes: 30, price_cents: 5000) }
  let(:client) { Client.create!(account: account, name: 'João', email: 'joao@test.com') }

  let(:appointment) do
    Appointment.create!(
      account: account,
      professional: pro,
      service: service,
      client: client,
      starts_at: Time.current + 1.day,
      ends_at: Time.current + 1.day + 30.minutes,
      status: :confirmed
    )
  end

  before do
    ActsAsTenant.current_tenant = account
  end

  after do
    ActsAsTenant.current_tenant = nil
  end

  describe '#call' do
    let(:new_time) { Time.current + 2.days }

    it 'reschedules appointment to new available time' do
      result = described_class.new(
        appointment: appointment,
        starts_at: new_time
      ).call

      expect(result.success?).to be true
      expect(appointment.reload.starts_at).to be_within(1.second).of(new_time)
      expect(appointment.ends_at).to be_within(1.second).of(new_time + 30.minutes)
    end

    it 'fails when new time has a conflict' do
      other_client = Client.create!(account: account, name: 'Maria', email: 'maria@test.com')
      Appointment.create!(
        account: account,
        professional: pro,
        service: service,
        client: client,
        starts_at: new_time,
        ends_at: new_time + 30.minutes,
        status: :confirmed
      )

      result = described_class.new(
        appointment: appointment,
        starts_at: new_time
      ).call

      expect(result.success?).to be false
      expect(result.errors).to include('O novo horário selecionado não está disponível.')
    end
  end
end
