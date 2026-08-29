# frozen_string_literal: true

module StripeServices
  class WebhookHandler
    def self.call(event)
      new(event).call
    end

    def initialize(event)
      @event = event
      @data = event.data.object
    end

    def call
      case @event.type
      when "checkout.session.completed"
        handle_checkout_session_completed
      when "customer.subscription.created", "customer.subscription.updated"
        handle_subscription_updated
      when "customer.subscription.deleted"
        handle_subscription_deleted
      when "invoice.payment_succeeded"
        handle_invoice_payment_succeeded
      when "invoice.payment_failed"
        handle_invoice_payment_failed
      end
    end

    private

    def get_val(obj, *keys)
      keys.reduce(obj) do |current, key|
        break nil if current.nil?

        if current.respond_to?(:[])
          val = current[key] || (key.is_a?(Symbol) ? current[key.to_s] : current[key.to_sym])
          val.nil? && current.respond_to?(key) ? current.public_send(key) : val
        elsif current.respond_to?(key)
          current.public_send(key)
        else
          nil
        end
      end
    end

    def handle_checkout_session_completed
      account_id = get_val(@data, :metadata, :account_id)
      account = Account.find_by(id: account_id)
      return unless account

      customer_id = get_val(@data, :customer)
      subscription_id = get_val(@data, :subscription)
      plan_interval = get_val(@data, :metadata, :plan_interval) || "monthly"

      stripe_sub = retrieve_stripe_subscription(subscription_id)

      price_id = get_val(stripe_sub, :items, :data)&.first&.then { |item| get_val(item, :price, :id) }
      period_start = get_val(stripe_sub, :current_period_start)&.then { |t| Time.zone.at(t) } || Time.current
      period_end = get_val(stripe_sub, :current_period_end)&.then { |t| Time.zone.at(t) } || 1.month.from_now
      cancel_at_end = get_val(stripe_sub, :cancel_at_period_end) || false

      ActsAsTenant.with_tenant(account) do
        subscription = account.subscription || account.build_subscription
        subscription.assign_attributes(
          stripe_customer_id: customer_id,
          stripe_subscription_id: subscription_id,
          stripe_price_id: price_id,
          plan_interval: plan_interval.to_s.downcase,
          status: :active,
          current_period_start: period_start,
          current_period_end: period_end,
          cancel_at_period_end: cancel_at_end
        )
        subscription.save!
      end
    end

    def handle_subscription_updated
      subscription = find_subscription(get_val(@data, :id), get_val(@data, :customer))
      return unless subscription

      status = map_stripe_status(get_val(@data, :status))
      first_item = get_val(@data, :items, :data)&.first
      price_id = first_item ? get_val(first_item, :price, :id) : nil

      period_start = get_val(@data, :current_period_start)&.then { |t| Time.zone.at(t) } || subscription.current_period_start
      period_end = get_val(@data, :current_period_end)&.then { |t| Time.zone.at(t) } || subscription.current_period_end
      cancel_at_end = get_val(@data, :cancel_at_period_end) || false

      ActsAsTenant.with_tenant(subscription.account) do
        subscription.update!(
          status: status,
          stripe_price_id: price_id || subscription.stripe_price_id,
          current_period_start: period_start,
          current_period_end: period_end,
          cancel_at_period_end: cancel_at_end
        )
      end
    end

    def handle_subscription_deleted
      subscription = find_subscription(get_val(@data, :id), get_val(@data, :customer))
      return unless subscription

      ActsAsTenant.with_tenant(subscription.account) do
        subscription.update!(status: :cancelled)
      end
    end

    def handle_invoice_payment_succeeded
      subscription_id = get_val(@data, :subscription)
      return unless subscription_id

      subscription = Subscription.find_by(stripe_subscription_id: subscription_id)
      return unless subscription

      ActsAsTenant.with_tenant(subscription.account) do
        subscription.update!(status: :active) if subscription.past_due? || subscription.incomplete?
      end
    end

    def handle_invoice_payment_failed
      subscription_id = get_val(@data, :subscription)
      return unless subscription_id

      subscription = Subscription.find_by(stripe_subscription_id: subscription_id)
      return unless subscription

      ActsAsTenant.with_tenant(subscription.account) do
        subscription.update!(status: :past_due)
      end
    end

    def find_subscription(subscription_id, customer_id)
      Subscription.find_by(stripe_subscription_id: subscription_id) ||
        Subscription.find_by(stripe_customer_id: customer_id)
    end

    def retrieve_stripe_subscription(subscription_id)
      return nil unless subscription_id.present?

      Stripe::Subscription.retrieve(subscription_id)
    rescue StandardError => e
      Rails.logger.warn("Falha ao recuperar assinatura Stripe #{subscription_id}: #{e.message}")
      nil
    end

    def map_stripe_status(stripe_status)
      case stripe_status.to_s
      when "active" then :active
      when "trialing" then :trialing
      when "past_due" then :past_due
      when "canceled" then :cancelled
      when "unpaid" then :unpaid
      when "incomplete" then :incomplete
      else :incomplete
      end
    end
  end
end
