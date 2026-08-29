# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhooks::Stripe', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-webhook-spec') }

  describe 'POST /webhooks/stripe' do
    let(:payload) do
      {
        id: 'evt_test_123',
        type: 'checkout.session.completed',
        data: {
          object: {
            id: 'cs_test_123',
            customer: 'cus_test_123',
            subscription: 'sub_test_123',
            metadata: {
              account_id: account.id,
              plan_interval: 'monthly'
            }
          }
        }
      }.to_json
    end

    context 'with valid webhook payload' do
      before do
        allow(StripeServices::WebhookHandler).to receive(:call).and_return(true)
      end

      it 'processes event and returns 200 ok' do
        post '/webhooks/stripe', params: payload, headers: { 'CONTENT_TYPE' => 'application/json' }
        expect(response).to have_http_status(:ok)
        expect(StripeServices::WebhookHandler).to have_received(:call)
      end
    end

    context 'with invalid signature' do
      before do
        allow(Rails.configuration).to receive(:stripe).and_return({ webhook_secret: 'whsec_test_secret' })
        allow(Stripe::Webhook).to receive(:construct_event).and_raise(Stripe::SignatureVerificationError.new('Invalid signature', 'sig_header'))
      end

      it 'returns 400 bad request' do
        post '/webhooks/stripe', params: payload, headers: { 'CONTENT_TYPE' => 'application/json', 'HTTP_STRIPE_SIGNATURE' => 'invalid_sig' }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'with malformed json' do
      before do
        allow(Rails.configuration).to receive(:stripe).and_return({ webhook_secret: nil })
      end

      it 'returns 400 bad request' do
        post '/webhooks/stripe', params: 'invalid json', headers: { 'CONTENT_TYPE' => 'application/json' }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
