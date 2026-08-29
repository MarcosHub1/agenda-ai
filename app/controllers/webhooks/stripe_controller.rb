# frozen_string_literal: true

module Webhooks
  class StripeController < ActionController::Base
    skip_before_action :verify_authenticity_token

    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = Rails.configuration.stripe[:webhook_secret]

      event = nil

      begin
        if endpoint_secret.present?
          event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
        else
          data = JSON.parse(payload, symbolize_names: true)
          event = Stripe::Event.construct_from(data)
        end
      rescue JSON::ParserError, Stripe::SignatureVerificationError => e
        Rails.logger.warn("Erro no webhook Stripe: #{e.message}")
        head :bad_request
        return
      rescue StandardError => e
        Rails.logger.error("Erro inesperado no webhook Stripe: #{e.message}")
        head :bad_request
        return
      end

      StripeServices::WebhookHandler.call(event)
      head :ok
    end
  end
end
