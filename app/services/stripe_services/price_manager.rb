# frozen_string_literal: true

module StripeServices
  class PriceManager
    PRODUCT_NAME = "AgendaAI Pro"

    FALLBACK_PRICE_IDS = {
      monthly: "price_monthly_agendaai_7990",
      yearly: "price_yearly_agendaai_54990"
    }.freeze

    def self.price_id_for(plan_interval)
      get_or_create_price(plan_interval)
    end

    def self.get_or_create_price(plan_interval)
      key = plan_interval.to_s.downcase.to_sym
      unless %i[monthly yearly].include?(key)
        raise ArgumentError, "Invalid plan interval: #{plan_interval}. Expected :monthly or :yearly."
      end

      env_key = key == :monthly ? "STRIPE_PRICE_MONTHLY_ID" : "STRIPE_PRICE_YEARLY_ID"
      price_id = ENV[env_key].presence || Rails.application.credentials.dig(:stripe, :"price_#{key}_id").presence

      return price_id if price_id.present?

      begin
        find_or_create_in_stripe(key)
      rescue StandardError => e
        Rails.logger.warn("Stripe Price API unavailable: #{e.message}. Using fallback ID.")
        FALLBACK_PRICE_IDS[key]
      end
    end

    def self.find_or_create_in_stripe(key)
      plan = Subscription::PLANS[key]
      product_id = find_or_create_product

      prices = Stripe::Price.list(product: product_id, active: true)
      existing = prices.data.find do |p|
        p.unit_amount == plan[:price_cents] &&
          p.currency == "brl" &&
          p.recurring&.interval == plan[:interval]
      end

      return existing.id if existing

      new_price = Stripe::Price.create(
        product: product_id,
        unit_amount: plan[:price_cents],
        currency: "brl",
        recurring: {
          interval: plan[:interval],
          interval_count: plan[:interval_count]
        },
        metadata: { plan_interval: key.to_s }
      )
      new_price.id
    end

    def self.find_or_create_product
      products = Stripe::Product.list(active: true)
      existing = products.data.find { |p| p.name == PRODUCT_NAME }
      return existing.id if existing

      product = Stripe::Product.create(
        name: PRODUCT_NAME,
        description: "Assinatura completa do AgendaAI com agendamentos ilimitados e gestão de equipe."
      )
      product.id
    end
  end
end
