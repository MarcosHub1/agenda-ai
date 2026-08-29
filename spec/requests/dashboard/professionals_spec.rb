# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Professionals', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-pro-spec') }
  let(:user) { User.create!(account: account, email_address: 'admin@navalha.com', password: 'password123', role: :owner) }
  let!(:service) { Service.create!(account: account, name: 'Corte Tradicional', duration_minutes: 30, price_cents: 4500) }

  before do
    sign_in_user(user)
  end

  describe 'GET /dashboard/professionals' do
    it 'lists professionals in the tenant' do
      pro = Professional.create!(account: account, name: 'Ricardo Santos', email: 'ricardo@test.com')
      get dashboard_professionals_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Ricardo Santos')
    end
  end

  describe 'POST /dashboard/professionals' do
    it 'creates a new professional with default work schedules and associates services' do
      expect do
        post dashboard_professionals_path, params: {
          professional: {
            name: 'Fernanda Lima',
            email: 'fernanda@test.com',
            active: true,
            service_ids: [ service.id ]
          }
        }
      end.to change(Professional, :count).by(1)

      pro = Professional.last
      expect(pro.name).to eq('Fernanda Lima')
      expect(pro.services).to include(service)
      expect(pro.work_schedules.count).to eq(7)
      expect(response).to redirect_to(dashboard_professional_path(pro))
    end
  end

  describe 'PATCH /dashboard/professionals/:id' do
    it 'updates professional attributes' do
      pro = Professional.create!(account: account, name: 'Antigo Nome', email: 'antigo@test.com')
      patch dashboard_professional_path(pro), params: {
        professional: {
          name: 'Novo Nome Atualizado'
        }
      }

      expect(response).to redirect_to(dashboard_professional_path(pro))
      expect(pro.reload.name).to eq('Novo Nome Atualizado')
    end
  end

  describe 'DELETE /dashboard/professionals/:id' do
    it 'destroys the professional' do
      pro = Professional.create!(account: account, name: 'Deletar Pro', email: 'del@test.com')
      expect do
        delete dashboard_professional_path(pro)
      end.to change(Professional, :count).by(-1)

      expect(response).to redirect_to(dashboard_professionals_path)
    end
  end
end
