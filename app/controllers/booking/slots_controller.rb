# frozen_string_literal: true

module Booking
  class SlotsController < BaseController
    def index
      @service = booking_tenant.services.find(params[:service_id])
      @professional = booking_tenant.professionals.find(params[:professional_id])

      @date = if params[:date].present?
                Date.parse(params[:date]) rescue Date.current
      else
                Date.current
      end

      calculator = Availability::SlotCalculator.new(
        professional: @professional,
        service: @service,
        date: @date
      )

      @slots = calculator.call
    end
  end
end
