# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeServices::CreatePortalSession do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-portal-test') }

  context 'when account has an existing subscription with stripe_customer_id' do
    before do
      account.create_subscription!(
        stripe_customer_id: 'cus_existing_789',
        plan_interval: :monthly,
        status: :active
      )
    end

    it 'creates a stripe billing portal session' do
      mock_portal = double('PortalSession', url: 'https://billing.stripe.com/p/session/portal_123')
      expect(Stripe::BillingPortal::Session).to receive(:create).with(
        customer: 'cus_existing_789',
        return_url: 'http://localhost:3000/dashboard/billing'
      ).and_return(mock_portal)

      result = described_class.new(
        account: account,
        return_url: 'http://localhost:3000/dashboard/billing'
      ).call

      expect(result.success?).to be true
      expect(result.portal_url).to eq('https://billing.stripe.com/p/session/portal_123')
    end
  end

  context 'when account has no stripe customer' do
    it 'returns error' do
      result = described_class.new(
        account: account,
        return_url: 'http://localhost:3000/dashboard/billing'
      ).call

      expect(result.success?).to be false
      expect(result.errors).to include('Nenhum cliente Stripe associado a esta conta.')
    end
  end
end
