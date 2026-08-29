# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Subscription Enforcement', type: :request do
  let(:account) { Account.create!(name: 'Studio Teste Sem Plano', slug: 'teste-sem-plano') }
  let(:user) { User.create!(account: account, email_address: 'dono@teste.com', password: 'password123', role: :owner) }

  before do
    sign_in_user(user, active_subscription: false)
  end

  it 'redirects /dashboard to /dashboard/billing with an alert' do
    get dashboard_root_path

    expect(response).to redirect_to(dashboard_billing_path)
    follow_redirect!
    expect(response.body).to include('Você precisa de uma assinatura ativa')
  end

  it 'redirects /dashboard/services to /dashboard/billing' do
    get dashboard_services_path

    expect(response).to redirect_to(dashboard_billing_path)
  end

  it 'redirects /dashboard/appointments to /dashboard/billing' do
    get dashboard_appointments_path

    expect(response).to redirect_to(dashboard_billing_path)
  end

  it 'redirects /dashboard/professionals to /dashboard/billing' do
    get dashboard_professionals_path

    expect(response).to redirect_to(dashboard_billing_path)
  end

  it 'allows access to /dashboard/billing to view plans and initiate checkout' do
    get dashboard_billing_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Planos & Assinatura')
    expect(response.body).to include('Plano Mensal')
    expect(response.body).to include('Plano Anual')
  end
end
