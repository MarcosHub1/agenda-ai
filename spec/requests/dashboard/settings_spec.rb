# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Settings', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-settings-spec') }
  let(:user) { User.create!(account: account, email_address: 'admin@navalha.com', password: 'password123', role: :owner) }

  before do
    sign_in_user(user)
  end

  describe 'GET /dashboard/settings' do
    it 'shows business settings' do
      get dashboard_settings_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Configurações do Estabelecimento')
      expect(response.body).to include('Barbearia Navalha')
    end
  end

  describe 'PATCH /dashboard/settings' do
    it 'updates business name and booking engine parameters' do
      patch dashboard_settings_path, params: {
        account: {
          name: 'Barbearia Navalha Prime',
          settings: {
            min_advance_hours: 4,
            max_advance_days: 60,
            slot_buffer_minutes: 10
          }
        }
      }

      expect(response).to redirect_to(dashboard_settings_path)
      account.reload
      expect(account.name).to eq('Barbearia Navalha Prime')
      expect(account.settings['min_advance_hours']).to eq(4)
      expect(account.settings['max_advance_days']).to eq(60)
      expect(account.settings['slot_buffer_minutes']).to eq(10)
    end
  end
end
