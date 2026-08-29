# frozen_string_literal: true

module AuthenticationHelpers
  def sign_in_user(user, password: "password123", active_subscription: true)
    if active_subscription && user.account && !user.account.active_subscription?
      Subscription.find_or_create_by!(account: user.account) do |sub|
        sub.plan_interval = :monthly
        sub.status = :active
        sub.current_period_start = Time.current
        sub.current_period_end = 1.month.from_now
      end
    end

    post session_path, params: { email_address: user.email_address, password: password }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
