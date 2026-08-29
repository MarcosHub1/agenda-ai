require 'rails_helper'

RSpec.describe Availability::SlotCalculator do
  let(:account) do
    Account.create!(
      name: 'Barbearia Navalha',
      slug: 'navalha-slot-test',
      timezone: 'America/Sao_Paulo',
      settings: {
        min_advance_hours: 2,
        max_advance_days: 30,
        slot_buffer_minutes: 0
      }
    )
  end
  let(:pro) { Professional.create!(account: account, name: 'Carlos', email: 'carlos@test.com') }
  let(:service) { Service.create!(account: account, name: 'Corte', duration_minutes: 30, price_cents: 4000) }
  let(:client) { Client.create!(account: account, name: 'João', email: 'joao@test.com') }

  # Next Monday
  let(:target_date) { Date.current.next_occurring(:monday) + 7.days }

  before do
    ActsAsTenant.current_tenant = account

    # Work Schedule: Monday 09:00 - 12:00, break 12:00-13:00, 13:00 - 17:00
    WorkSchedule.create!(
      professional: pro,
      day_of_week: 1, # Monday
      start_time: '09:00',
      end_time: '17:00',
      break_start: '12:00',
      break_end: '13:00',
      enabled: true
    )
  end

  after do
    ActsAsTenant.current_tenant = nil
  end

  describe '#call' do
    it 'generates slots of 30 minutes excluding the lunch break' do
      calculator = described_class.new(professional: pro, service: service, date: target_date)
      slots = calculator.call

      expect(slots).not_to be_empty
      expect(slots.first[:starts_at].strftime('%H:%M')).to eq('09:00')
      expect(slots.first[:ends_at].strftime('%H:%M')).to eq('09:30')
      expect(slots.first[:available]).to be true

      # Check lunch break excluded (12:00 - 13:00)
      slot_times = slots.map { |s| s[:starts_at].strftime('%H:%M') }
      expect(slot_times).not_to include('12:00')
      expect(slot_times).not_to include('12:30')
      expect(slot_times).to include('11:30')
      expect(slot_times).to include('13:00')
      expect(slot_times).to include('16:30')
      expect(slot_times).not_to include('17:00')
    end

    context 'when an appointment already exists' do
      before do
        start_t = target_date.in_time_zone(account.timezone).change(hour: 10, min: 0)
        Appointment.create!(
          account: account,
          professional: pro,
          service: service,
          client: client,
          starts_at: start_t,
          ends_at: start_t + 30.minutes,
          status: :confirmed
        )
      end

      it 'marks the conflicting slot as unavailable' do
        calculator = described_class.new(professional: pro, service: service, date: target_date)
        slots = calculator.call

        slot_10 = slots.find { |s| s[:starts_at].strftime('%H:%M') == '10:00' }
        expect(slot_10[:available]).to be false

        slot_0930 = slots.find { |s| s[:starts_at].strftime('%H:%M') == '09:30' }
        expect(slot_0930[:available]).to be true
      end
    end

    context 'when a full-day schedule exception blocks the day' do
      before do
        ScheduleException.create!(
          professional: pro,
          exception_date: target_date,
          is_blocked: true,
          reason: 'Feriado'
        )
      end

      it 'returns an empty list of slots' do
        calculator = described_class.new(professional: pro, service: service, date: target_date)
        expect(calculator.call).to be_empty
      end
    end

    context 'when the day of the week is disabled in WorkSchedule' do
      let(:sunday_date) { Date.current.next_occurring(:sunday) + 7.days }

      it 'returns an empty list of slots' do
        calculator = described_class.new(professional: pro, service: service, date: sunday_date)
        expect(calculator.call).to be_empty
      end
    end

    context 'when date exceeds max_advance_days' do
      let(:far_future_date) { Date.current + 45.days }

      it 'returns an empty list of slots' do
        calculator = described_class.new(professional: pro, service: service, date: far_future_date)
        expect(calculator.call).to be_empty
      end
    end
  end
end
