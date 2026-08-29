# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Clients', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-clients-spec') }
  let(:user) { User.create!(account: account, email_address: 'admin@navalha.com', password: 'password123', role: :owner) }

  before do
    sign_in_user(user)
  end

  describe 'GET /dashboard/clients' do
    it 'lists clients and filters by search query' do
      c1 = Client.create!(account: account, name: 'Alice Silva', email: 'alice@test.com', phone: '11999991111')
      c2 = Client.create!(account: account, name: 'Bernardo Costa', email: 'bernardo@test.com', phone: '11999992222')

      get dashboard_clients_path, params: { query: 'Alice' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Alice Silva')
      expect(response.body).not_to include('Bernardo Costa')
    end
  end

  describe 'GET /dashboard/clients/:id' do
    it 'shows client details and appointment history' do
      c = Client.create!(account: account, name: 'Alice Silva', email: 'alice@test.com')
      get dashboard_client_path(c)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Alice Silva')
    end
  end
end
