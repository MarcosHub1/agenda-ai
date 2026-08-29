# frozen_string_literal: true

module Booking
  class ProfessionalsController < BaseController
    def index
      @service = booking_tenant.services.find(params[:service_id]) if params[:service_id].present?

      @professionals = if @service
                         @service.professionals.where(active: true).order(:name)
      else
                         booking_tenant.professionals.where(active: true).order(:name)
      end
    end
  end
end
