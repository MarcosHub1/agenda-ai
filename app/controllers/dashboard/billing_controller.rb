# frozen_string_literal: true

module Dashboard
  class BillingController < BaseController
    before_action :authorize_billing

    def show
      @subscription = current_tenant.subscription
      @plans = Subscription::PLANS
    end

    def checkout
      plan_interval = params[:plan_interval].presence || "monthly"
      success_url = success_dashboard_billing_url(session_id: "{CHECKOUT_SESSION_ID}")
      cancel_url = cancel_dashboard_billing_url

      result = StripeServices::CreateCheckoutSession.call(
        account: current_tenant,
        user: current_user,
        plan_interval: plan_interval,
        success_url: success_url,
        cancel_url: cancel_url
      )

      if result.success?
        redirect_to result.session_url, allow_other_host: true
      else
        redirect_to dashboard_billing_path, alert: "Não foi possível iniciar o checkout: #{result.errors.join(', ')}"
      end
    end

    def portal
      return_url = dashboard_billing_url

      result = StripeServices::CreatePortalSession.call(
        account: current_tenant,
        return_url: return_url
      )

      if result.success?
        redirect_to result.portal_url, allow_other_host: true
      else
        redirect_to dashboard_billing_path, alert: "Não foi possível acessar o portal: #{result.errors.join(', ')}"
      end
    end

    def success
      @subscription = current_tenant.subscription
    end

    def cancel; end

    private

    def authorize_billing
      record = current_tenant.subscription || Subscription.new(account: current_tenant)
      authorize record, policy_class: SubscriptionPolicy
    end
  end
end
