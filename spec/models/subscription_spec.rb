# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-sub-test') }

  it 'belongs to an account and acts as tenant' do
    subscription = described_class.create!(
      account: account,
      plan_interval: :monthly,
      status: :active,
      stripe_customer_id: 'cus_123',
      stripe_subscription_id: 'sub_123'
    )

    expect(subscription.account).to eq(account)
    expect(subscription.plan_name).to eq('Plano Mensal')
    expect(subscription.amount_formatted).to eq('R$ 79,90')
    expect(subscription.active_or_trialing?).to be true
  end

  it 'supports yearly plan' do
    subscription = described_class.create!(
      account: account,
      plan_interval: :yearly,
      status: :trialing,
      stripe_customer_id: 'cus_456'
    )

    expect(subscription.yearly?).to be true
    expect(subscription.plan_name).to eq('Plano Anual')
    expect(subscription.amount_formatted).to eq('R$ 549,90')
    expect(account.active_subscription?).to be true
  end
end
