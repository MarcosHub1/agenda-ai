# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Appointments::Canceller do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-canceller-test') }
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
    it 'cancels the appointment successfully and stores cancellation reason' do
      result = described_class.new(appointment: appointment, reason: 'Cliente solicitou cancelamento').call

      expect(result.success?).to be true
      expect(appointment.reload.status).to eq('cancelled')
      expect(appointment.cancellation_reason).to eq('Cliente solicitou cancelamento')
    end

    it 'returns error if already cancelled' do
      appointment.update!(status: :cancelled)
      result = described_class.new(appointment: appointment).call

      expect(result.success?).to be false
      expect(result.errors).to include('Este agendamento já está cancelado.')
    end
  end
end
