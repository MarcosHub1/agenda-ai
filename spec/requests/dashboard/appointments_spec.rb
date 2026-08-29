# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Appointments', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-appt-spec') }
  let(:user) { User.create!(account: account, email_address: 'admin@navalha.com', password: 'password123', role: :owner) }
  let(:pro) { Professional.create!(account: account, name: 'Lucas', email: 'lucas@test.com') }
  let(:service) { Service.create!(account: account, name: 'Corte', duration_minutes: 30, price_cents: 5000) }
  let(:client) { Client.create!(account: account, name: 'Pedro Alves', email: 'pedro@test.com', phone: '11999990000') }

  let(:appointment) do
    Appointment.create!(
      account: account,
      professional: pro,
      service: service,
      client: client,
      starts_at: Time.current + 1.day,
      ends_at: Time.current + 1.day + 30.minutes,
      status: :pending,
      price_cents: 5000
    )
  end

  before do
    sign_in_user(user)
  end

  describe 'GET /dashboard/appointments' do
    it 'lists appointments and responds with 200' do
      appointment
      get dashboard_appointments_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Pedro Alves')
    end
  end

  describe 'POST /dashboard/appointments' do
    it 'creates a new manual appointment via admin' do
      expect do
        post dashboard_appointments_path, params: {
          appointment: {
            service_id: service.id,
            professional_id: pro.id,
            client_name: 'Novo Cliente Manual',
            client_phone: '(11) 98888-7777',
            client_email: 'manual@test.com',
            starts_at: (Time.current + 2.days).change(hour: 14, min: 0).strftime('%Y-%m-%dT%H:%M'),
            status: 'confirmed'
          }
        }
      end.to change(Appointment, :count).by(1)

      expect(response).to redirect_to(dashboard_appointment_path(Appointment.last))
    end
  end

  describe 'PATCH /dashboard/appointments/:id/confirm' do
    it 'confirms a pending appointment' do
      patch confirm_dashboard_appointment_path(appointment)
      expect(appointment.reload.status).to eq('confirmed')
    end
  end

  describe 'PATCH /dashboard/appointments/:id/cancel' do
    it 'cancels the appointment' do
      patch cancel_dashboard_appointment_path(appointment), params: { cancellation_reason: 'Cliente avisou que não vai' }
      expect(appointment.reload.status).to eq('cancelled')
      expect(appointment.cancellation_reason).to eq('Cliente avisou que não vai')
    end
  end

  describe 'PATCH /dashboard/appointments/:id/complete' do
    it 'marks the appointment as completed' do
      patch complete_dashboard_appointment_path(appointment)
      expect(appointment.reload.status).to eq('completed')
    end
  end
end
