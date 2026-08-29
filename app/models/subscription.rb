# frozen_string_literal: true

class Subscription < ApplicationRecord
  acts_as_tenant :account

  belongs_to :account

  enum :plan_interval, { monthly: 0, yearly: 1 }
  enum :status, { trialing: 0, active: 1, past_due: 2, cancelled: 3, unpaid: 4, incomplete: 5 }

  PLANS = {
    monthly: {
      id: "monthly",
      name: "Plano Mensal",
      price_cents: 7990,
      interval: "month",
      interval_count: 1,
      amount_formatted: "R$ 79,90"
    },
    yearly: {
      id: "yearly",
      name: "Plano Anual",
      price_cents: 54990,
      interval: "year",
      interval_count: 1,
      amount_formatted: "R$ 549,90",
      monthly_equivalent: "R$ 45,82",
      savings: "42%"
    }
  }.freeze

  def active_or_trialing?
    active? || trialing?
  end

  def plan_name
    PLANS.dig(plan_interval&.to_sym, :name) || "Plano Pro"
  end

  def amount_formatted
    PLANS.dig(plan_interval&.to_sym, :amount_formatted) || "R$ 79,90"
  end
end
