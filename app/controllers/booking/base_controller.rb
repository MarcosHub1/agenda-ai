# frozen_string_literal: true

module Booking
  class BaseController < ApplicationController
    allow_unauthenticated_access
    layout "booking"

    before_action :ensure_tenant!

    helper_method :booking_tenant

    private

    def ensure_tenant!
      @booking_tenant = Account.find_by(slug: params[:tenant_slug])
      if @booking_tenant.nil? || @booking_tenant.suspended?
        render "booking/errors/not_found", status: :not_found, layout: "booking"
        return
      end

      unless @booking_tenant.active_subscription?
        render "booking/errors/subscription_required", status: :forbidden, layout: "booking"
        return
      end

      set_current_tenant(@booking_tenant)
    end

    def booking_tenant
      @booking_tenant
    end
  end
end
