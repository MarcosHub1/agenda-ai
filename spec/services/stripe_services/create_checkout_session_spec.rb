# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeServices::CreateCheckoutSession do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-chk-test') }
  let(:user) { User.create!(account: account, email_address: 'admin@navalha.com', password: 'password123', role: :owner) }

  before do
    allow(StripeServices::PriceManager).to receive(:get_or_create_price).with(:monthly).and_return('price_monthly_123')
    allow(Stripe::Customer).to receive(:create).and_return(double('Customer', id: 'cus_new_123'))
  end

  it 'creates a stripe checkout session for subscription' do
    mock_session = double('StripeCheckoutSession', url: 'https://checkout.stripe.com/pay/cs_test_123')
    expect(Stripe::Checkout::Session).to receive(:create).with(
      hash_including(
        customer: 'cus_new_123',
        mode: 'subscription',
        success_url: 'http://localhost:3000/success',
        cancel_url: 'http://localhost:3000/cancel'
      )
    ).and_return(mock_session)

    result = described_class.new(
      account: account,
      user: user,
      plan_interval: :monthly,
      success_url: 'http://localhost:3000/success',
      cancel_url: 'http://localhost:3000/cancel'
    ).call

    expect(result.success?).to be true
    expect(result.session_url).to eq('https://checkout.stripe.com/pay/cs_test_123')
  end
end
