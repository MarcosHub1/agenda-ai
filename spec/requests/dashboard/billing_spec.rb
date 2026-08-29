# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Billing', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-billing-spec') }
  let(:owner) { User.create!(account: account, email_address: 'owner@navalha.com', password: 'password123', role: :owner) }
  let(:professional_user) { User.create!(account: account, email_address: 'pro@navalha.com', password: 'password123', role: :professional) }

  context 'when authenticated as owner' do
    before do
      sign_in_user(owner, active_subscription: false)
    end

    describe 'GET /dashboard/billing' do
      it 'renders billing page successfully' do
        get dashboard_billing_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Planos & Assinatura')
        expect(response.body).to include('Plano Mensal')
        expect(response.body).to include('Plano Anual')
      end

      it 'shows active subscription status if subscribed' do
        Subscription.create!(
          account: account,
          plan_interval: :yearly,
          status: :active,
          stripe_customer_id: 'cus_spec_123',
          stripe_subscription_id: 'sub_spec_123'
        )

        get dashboard_billing_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Ativa')
        expect(response.body).to include('Plano Anual')
      end
    end

    describe 'POST /dashboard/billing/checkout' do
      it 'redirects to Stripe Checkout session URL' do
        mock_result = StripeServices::CreateCheckoutSession::Result.new(
          success: true,
          session_url: 'https://checkout.stripe.com/c/pay/cs_test_checkout',
          errors: []
        )

        expect(StripeServices::CreateCheckoutSession).to receive(:call).with(
          account: account,
          user: owner,
          plan_interval: 'monthly',
          success_url: a_string_including('/dashboard/billing/success'),
          cancel_url: a_string_including('/dashboard/billing/cancel')
        ).and_return(mock_result)

        post checkout_dashboard_billing_path, params: { plan_interval: 'monthly' }
        expect(response).to redirect_to('https://checkout.stripe.com/c/pay/cs_test_checkout')
      end

      it 'handles failure gracefully and redirects with alert' do
        mock_result = StripeServices::CreateCheckoutSession::Result.new(
          success: false,
          errors: [ 'Stripe API error' ]
        )

        expect(StripeServices::CreateCheckoutSession).to receive(:call).and_return(mock_result)

        post checkout_dashboard_billing_path, params: { plan_interval: 'monthly' }
        expect(response).to redirect_to(dashboard_billing_path)
        follow_redirect!
        expect(response.body).to include('Não foi possível iniciar o checkout')
      end
    end

    describe 'POST /dashboard/billing/portal' do
      it 'redirects to Stripe Billing Portal URL' do
        Subscription.create!(
          account: account,
          plan_interval: :monthly,
          status: :active,
          stripe_customer_id: 'cus_spec_123'
        )

        mock_result = StripeServices::CreatePortalSession::Result.new(
          success: true,
          portal_url: 'https://billing.stripe.com/p/session/pts_spec',
          errors: []
        )

        expect(StripeServices::CreatePortalSession).to receive(:call).with(
          account: account,
          return_url: a_string_including('/dashboard/billing')
        ).and_return(mock_result)

        post portal_dashboard_billing_path
        expect(response).to redirect_to('https://billing.stripe.com/p/session/pts_spec')
      end
    end

    describe 'GET /dashboard/billing/success' do
      it 'renders success page' do
        get success_dashboard_billing_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Assinatura Confirmada')
      end
    end

    describe 'GET /dashboard/billing/cancel' do
      it 'renders cancel page' do
        get cancel_dashboard_billing_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Checkout Cancelado')
      end
    end
  end

  context 'when authenticated as non-admin/non-owner (e.g. professional)' do
    before do
      sign_in_user(professional_user, active_subscription: false)
    end

    it 'denies access to billing settings' do
      expect {
        get dashboard_billing_path
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
