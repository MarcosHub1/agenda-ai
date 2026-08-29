# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public Booking Flow', type: :request do
  let(:account) { Account.create!(name: 'Studio Beleza Pura', slug: 'beleza-pura', timezone: 'America/Sao_Paulo') }
  let(:pro) { Professional.create!(account: account, name: 'Juliana Silva', email: 'juliana@test.com', active: true) }
  let(:service) { Service.create!(account: account, name: 'Manicure Completa', duration_minutes: 45, price_cents: 6000, active: true) }

  before do
    Subscription.create!(account: account, plan_interval: :monthly, status: :active, current_period_end: 1.month.from_now)

    # Assign service to professional
    pro.services << service

    # Create work schedule (Mon-Fri 09:00 - 18:00)
    (1..5).each do |day|
      pro.work_schedules.create!(
        day_of_week: day,
        start_time: '09:00',
        end_time: '18:00',
        break_start: '12:00',
        break_end: '13:00',
        enabled: true
      )
    end
  end

  describe 'Inactive Subscription Blocking' do
    it 'returns 403 forbidden if tenant has no active subscription' do
      account.subscription.destroy
      get booking_path(tenant_slug: account.slug)

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include('Agendamentos Temporariamente Indisponíveis')
    end
  end

  describe 'Step 1: Services List (GET /:tenant_slug)' do
    it 'renders the public catalog of services' do
      get booking_path(tenant_slug: account.slug)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Studio Beleza Pura')
      expect(response.body).to include('Manicure Completa')
    end

    it 'returns 404 if tenant slug is not found' do
      get booking_path(tenant_slug: 'tenant-inexistente')
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('Página de Agendamento Não Encontrada')
    end
  end

  describe 'Step 2: Professionals Selection (GET /:tenant_slug/professionals)' do
    it 'lists professionals that perform the service' do
      get booking_professionals_path(tenant_slug: account.slug, service_id: service.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Juliana Silva')
    end
  end

  describe 'Step 3: Slots & Date Picker (GET /:tenant_slug/slots)' do
    it 'calculates and shows available time slots for a business day' do
      target_date = Date.current.next_occurring(:tuesday)
      get booking_slots_path(tenant_slug: account.slug, service_id: service.id, professional_id: pro.id, date: target_date)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('09:00')
      expect(response.body).to include('Manicure Completa')
    end
  end

  describe 'Step 4: Customer Details Form (GET /:tenant_slug/appointments/new)' do
    it 'renders the customer details form for the chosen slot' do
      target_time = (Time.current + 2.days).change(hour: 10, min: 0)
      get new_booking_appointment_path(
        tenant_slug: account.slug,
        service_id: service.id,
        professional_id: pro.id,
        starts_at: target_time.iso8601
      )

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Seus Dados e Confirmação')
      expect(response.body).to include('Manicure Completa')
      expect(response.body).to include('Juliana Silva')
    end
  end

  describe 'Step 5: Create Appointment & Confirmation (POST /:tenant_slug/appointments)' do
    let(:target_time) { (Time.current + 3.days).change(hour: 14, min: 0) }

    it 'creates the client and appointment without requiring login, and redirects to confirmation' do
      expect do
        post booking_appointments_path(tenant_slug: account.slug), params: {
          appointment: {
            service_id: service.id,
            professional_id: pro.id,
            starts_at: target_time.iso8601,
            client_name: 'Camila Rodrigues',
            client_phone: '(11) 98765-4321',
            client_email: 'camila@email.com',
            notes: 'Primeira vez no salão'
          }
        }
      end.to change(Appointment, :count).by(1).and change(Client, :count).by(1)

      appointment = Appointment.last
      expect(appointment.client.name).to eq('Camila Rodrigues')
      expect(appointment.client.phone).to eq('(11) 98765-4321')
      expect(appointment.client.email).to eq('camila@email.com')
      expect(appointment.status).to eq('pending')
      expect(appointment.price_cents).to eq(6000)

      expect(response).to redirect_to(booking_appointment_path(tenant_slug: account.slug, id: appointment.id))

      # Follow redirect to confirmation ticket
      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Agendamento Realizado!')
      expect(response.body).to include('Camila Rodrigues')
      expect(response.body).to include('Studio Beleza Pura')
    end
  end
end
