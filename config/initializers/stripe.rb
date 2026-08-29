# frozen_string_literal: true

require "stripe"

Stripe.api_key = ENV["STRIPE_SECRET_KEY"] || Rails.application.credentials.dig(:stripe, :secret_key)

Rails.configuration.stripe = {
  publishable_key: ENV["STRIPE_PUBLISHABLE_KEY"] || Rails.application.credentials.dig(:stripe, :publishable_key),
  secret_key: Stripe.api_key,
  webhook_secret: ENV["STRIPE_WEBHOOK_SECRET"] || Rails.application.credentials.dig(:stripe, :webhook_secret)
}
