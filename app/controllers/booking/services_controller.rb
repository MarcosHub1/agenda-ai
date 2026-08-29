# frozen_string_literal: true

module Booking
  class ServicesController < BaseController
    def index
      @services = booking_tenant.services.where(active: true).order(:sort_order, :name)
    end
  end
end
