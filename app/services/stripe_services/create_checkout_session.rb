# frozen_string_literal: true

module StripeServices
  class CreateCheckoutSession
    Result = Struct.new(:success, :session, :session_url, :errors, keyword_init: true) do
      def success?
        success == true
      end
    end

    def self.call(account:, user:, plan_interval:, success_url:, cancel_url:)
      new(account: account, user: user, plan_interval: plan_interval, success_url: success_url, cancel_url: cancel_url).call
    end

    def initialize(account:, user:, plan_interval:, success_url:, cancel_url:)
      @account = account
      @user = user
      @plan_interval = plan_interval.to_s.downcase.to_sym
      @success_url = success_url
      @cancel_url = cancel_url
    end

    def call
      price_id = PriceManager.price_id_for(@plan_interval)
      customer_id = find_or_create_customer_id

      session_params = {
        mode: "subscription",
        payment_method_types: [ "card" ],
        line_items: [ { price: price_id, quantity: 1 } ],
        metadata: {
          account_id: @account.id,
          plan_interval: @plan_interval.to_s
        },
        subscription_data: {
          metadata: {
            account_id: @account.id,
            plan_interval: @plan_interval.to_s
          }
        },
        success_url: @success_url,
        cancel_url: @cancel_url,
        allow_promotion_codes: true
      }

      session_params[:customer] = customer_id if customer_id.present?

      session = Stripe::Checkout::Session.create(session_params)
      Result.new(success: true, session: session, session_url: session.url, errors: [])
    rescue StandardError => e
      Result.new(success: false, errors: [ e.message ])
    end

    private

    def find_or_create_customer_id
      return @account.subscription.stripe_customer_id if @account.subscription&.stripe_customer_id.present?

      customer = Stripe::Customer.create(
        email: @user&.email_address,
        name: @account.name,
        metadata: { account_id: @account.id }
      )
      customer.id
    rescue StandardError
      nil
    end
  end
end
