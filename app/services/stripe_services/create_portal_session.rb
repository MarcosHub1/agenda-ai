# frozen_string_literal: true

module StripeServices
  class CreatePortalSession
    Result = Struct.new(:success, :session, :portal_url, :errors, keyword_init: true) do
      def success?
        success == true
      end
    end

    def self.call(account:, return_url:)
      new(account: account, return_url: return_url).call
    end

    def initialize(account:, return_url:)
      @account = account
      @return_url = return_url
    end

    def call
      customer_id = @account.subscription&.stripe_customer_id
      if customer_id.blank?
        return Result.new(success: false, portal_url: nil, errors: [ "Nenhum cliente Stripe associado a esta conta." ])
      end

      session = Stripe::BillingPortal::Session.create(
        customer: customer_id,
        return_url: @return_url
      )
      Result.new(success: true, session: session, portal_url: session.url, errors: [])
    rescue StandardError => e
      Result.new(success: false, portal_url: nil, errors: [ e.message ])
    end
  end
end
