# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeServices::WebhookHandler do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-webhook-test') }

  describe 'checkout.session.completed' do
    it 'creates an active subscription for the account' do
      session_data = {
        mode: 'subscription',
        customer: 'cus_wh_123',
        subscription: 'sub_wh_123',
        metadata: {
          account_id: account.id,
          plan_interval: 'yearly'
        }
      }

      event = Stripe::Event.construct_from(
        id: 'evt_123',
        type: 'checkout.session.completed',
        data: { object: session_data }
      )

      allow(Stripe::Subscription).to receive(:retrieve).with('sub_wh_123').and_return(
        double(
          'StripeSub',
          items: double('Items', data: [ double('Item', price: double('Price', id: 'price_yearly_999')) ]),
          current_period_start: Time.current.to_i,
          current_period_end: (Time.current + 1.year).to_i,
          cancel_at_period_end: false
        )
      )

      described_class.new(event).call

      subscription = account.reload.subscription
      expect(subscription).to be_present
      expect(subscription.stripe_customer_id).to eq('cus_wh_123')
      expect(subscription.stripe_subscription_id).to eq('sub_wh_123')
      expect(subscription.yearly?).to be true
      expect(subscription.active?).to be true
    end
  end

  describe 'customer.subscription.updated' do
    it 'updates the subscription status and dates' do
      sub = account.create_subscription!(
        stripe_customer_id: 'cus_upd_123',
        stripe_subscription_id: 'sub_upd_123',
        plan_interval: :monthly,
        status: :active
      )

      event = Stripe::Event.construct_from(
        id: 'evt_upd_123',
        type: 'customer.subscription.updated',
        data: {
          object: {
            id: 'sub_upd_123',
            customer: 'cus_upd_123',
            status: 'past_due',
            cancel_at_period_end: true
          }
        }
      )

      described_class.new(event).call

      sub.reload
      expect(sub.past_due?).to be true
      expect(sub.cancel_at_period_end).to be true
    end
  end

  describe 'customer.subscription.deleted' do
    it 'cancels the subscription' do
      sub = account.create_subscription!(
        stripe_customer_id: 'cus_del_123',
        stripe_subscription_id: 'sub_del_123',
        plan_interval: :monthly,
        status: :active
      )

      event = Stripe::Event.construct_from(
        id: 'evt_456',
        type: 'customer.subscription.deleted',
        data: {
          object: {
            id: 'sub_del_123',
            customer: 'cus_del_123'
          }
        }
      )

      described_class.new(event).call

      expect(sub.reload.cancelled?).to be true
    end
  end

  describe 'invoice.payment_succeeded' do
    it 'reactivates a past_due subscription' do
      sub = account.create_subscription!(
        stripe_customer_id: 'cus_inv_123',
        stripe_subscription_id: 'sub_inv_123',
        plan_interval: :monthly,
        status: :past_due
      )

      event = Stripe::Event.construct_from(
        id: 'evt_inv_1',
        type: 'invoice.payment_succeeded',
        data: {
          object: {
            subscription: 'sub_inv_123'
          }
        }
      )

      described_class.new(event).call

      expect(sub.reload.active?).to be true
    end
  end

  describe 'invoice.payment_failed' do
    it 'marks subscription as past_due' do
      sub = account.create_subscription!(
        stripe_customer_id: 'cus_fail_123',
        stripe_subscription_id: 'sub_fail_123',
        plan_interval: :monthly,
        status: :active
      )

      event = Stripe::Event.construct_from(
        id: 'evt_inv_2',
        type: 'invoice.payment_failed',
        data: {
          object: {
            subscription: 'sub_fail_123'
          }
        }
      )

      described_class.new(event).call

      expect(sub.reload.past_due?).to be true
    end
  end
end
