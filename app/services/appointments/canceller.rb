# frozen_string_literal: true

module Appointments
  class Canceller
    Result = Struct.new(:success, :appointment, :errors, keyword_init: true) do
      def success?
        success == true
      end
    end

    attr_reader :appointment, :reason

    def initialize(appointment:, reason: nil)
      @appointment = appointment
      @reason = reason
    end

    def call
      if appointment.cancelled?
        return Result.new(success: false, appointment: appointment, errors: [ "Este agendamento já está cancelado." ])
      end

      appointment.status = :cancelled
      appointment.cancellation_reason = reason if reason.present?

      if appointment.save
        Result.new(success: true, appointment: appointment, errors: [])
      else
        Result.new(success: false, appointment: appointment, errors: appointment.errors.full_messages)
      end
    rescue StandardError => e
      Result.new(success: false, appointment: appointment, errors: [ e.message ])
    end
  end
end
