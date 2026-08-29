# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Services', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-services-spec') }
  let(:user) { User.create!(account: account, email_address: 'admin@navalha.com', password: 'password123', role: :owner) }

  before do
    sign_in_user(user)
  end

  describe 'GET /dashboard/services' do
    it 'lists services in the tenant' do
      srv = Service.create!(account: account, name: 'Barba Terapia', duration_minutes: 40, price_cents: 6000)
      get dashboard_services_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Barba Terapia')
    end
  end

  describe 'POST /dashboard/services' do
    it 'creates a new service with price conversion' do
      expect do
        post dashboard_services_path, params: {
          service: {
            name: 'Limpeza de Pele',
            description: 'Tratamento facial profundo',
            duration_minutes: 45,
            price: '85,00',
            active: true
          }
        }
      end.to change(Service, :count).by(1)

      srv = Service.last
      expect(srv.name).to eq('Limpeza de Pele')
      expect(srv.price_cents).to eq(8500)
      expect(srv.duration_minutes).to eq(45)
      expect(response).to redirect_to(dashboard_services_path)
    end
  end

  describe 'DELETE /dashboard/services/:id' do
    it 'deletes a service' do
      srv = Service.create!(account: account, name: 'Serviço Velho', duration_minutes: 30, price_cents: 3000)
      expect do
        delete dashboard_service_path(srv)
      end.to change(Service, :count).by(-1)

      expect(response).to redirect_to(dashboard_services_path)
    end
  end
end
