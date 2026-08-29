# frozen_string_literal: true

module Booking
  class AppointmentsController < BaseController
    before_action :set_collections, only: %i[new create]

    def new
      @starts_at = Time.zone.parse(params[:starts_at]) rescue nil
      if @service.nil? || @professional.nil? || @starts_at.nil?
        redirect_to booking_path(tenant_slug: booking_tenant.slug), alert: "Por favor, selecione o serviço, profissional e horário."
        return
      end

      @appointment = booking_tenant.appointments.build(
        service: @service,
        professional: @professional,
        starts_at: @starts_at,
        price_cents: @service.price_cents
      )
    end

    def create
      if @service.nil? || @professional.nil?
        redirect_to booking_path(tenant_slug: booking_tenant.slug), alert: "Dados inválidos para agendamento."
        return
      end

      client_params = {
        name: params.dig(:appointment, :client_name),
        email: params.dig(:appointment, :client_email),
        phone: params.dig(:appointment, :client_phone)
      }

      result = Appointments::Creator.new(
        account: booking_tenant,
        professional: @professional,
        service: @service,
        starts_at: params.dig(:appointment, :starts_at),
        client_params: client_params,
        notes: params.dig(:appointment, :notes)
      ).call

      if result.success?
        redirect_to booking_appointment_path(tenant_slug: booking_tenant.slug, id: result.appointment.id)
      else
        @starts_at = Time.zone.parse(params.dig(:appointment, :starts_at)) rescue nil
        @appointment = booking_tenant.appointments.build(
          service: @service,
          professional: @professional,
          starts_at: @starts_at,
          price_cents: @service.price_cents,
          notes: params.dig(:appointment, :notes)
        )
        @client_name = client_params[:name]
        @client_email = client_params[:email]
        @client_phone = client_params[:phone]
        flash.now[:alert] = result.errors.join(", ")
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @appointment = booking_tenant.appointments.find(params[:id])
    end

    private

    def set_collections
      service_id = params[:service_id] || params.dig(:appointment, :service_id)
      professional_id = params[:professional_id] || params.dig(:appointment, :professional_id)

      @service = booking_tenant.services.find_by(id: service_id)
      @professional = booking_tenant.professionals.find_by(id: professional_id)
    end
  end
end
