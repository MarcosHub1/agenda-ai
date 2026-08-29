# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Home', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-dashboard-test') }
  let(:user) { User.create!(account: account, email_address: 'admin@navalha.com', password: 'password123', role: :owner) }

  context 'when not authenticated' do
    it 'redirects to login' do
      get dashboard_root_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context 'when authenticated' do
    before do
      sign_in_user(user)
    end

    it 'renders the dashboard overview successfully' do
      get dashboard_root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Barbearia Navalha')
      expect(response.body).to include('Visão Geral')
    end
  end
end
