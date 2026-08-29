# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    account
    plan_interval { :monthly }
    status { :active }
    stripe_customer_id { "cus_#{SecureRandom.hex(8)}" }
    stripe_subscription_id { "sub_#{SecureRandom.hex(8)}" }
    stripe_price_id { "price_#{SecureRandom.hex(8)}" }
    current_period_start { Time.current }
    current_period_end { 1.month.from_now }
    cancel_at_period_end { false }
  end
end
