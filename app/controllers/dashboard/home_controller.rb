# frozen_string_literal: true

module Dashboard
  class HomeController < BaseController
    def index
      today = Date.current
      account = current_tenant

      @today_appointments = account.appointments
                                   .where("starts_at >= ? AND starts_at <= ?", today.beginning_of_day, today.end_of_day)
                                   .order(:starts_at)

      @pending_count = account.appointments.where(status: :pending).count
      @confirmed_count = account.appointments.where(status: :confirmed).count

      @upcoming_appointments = account.appointments
                                      .where("starts_at >= ?", Time.current)
                                      .where(status: %i[pending confirmed])
                                      .order(:starts_at)
                                      .limit(5)

      @professionals_count = account.professionals.where(active: true).count
      @services_count = account.services.where(active: true).count
      @clients_count = account.clients.count

      # Total revenue for current month (confirmed + completed)
      month_start = today.beginning_of_month
      month_end = today.end_of_month
      @month_revenue_cents = account.appointments
                                    .where("starts_at >= ? AND starts_at <= ?", month_start, month_end)
                                    .where(status: %i[confirmed completed])
                                    .sum(:price_cents)
    end
  end
end
