# frozen_string_literal: true

module Appointments
  class Rescheduler
    Result = Struct.new(:success, :appointment, :errors, keyword_init: true) do
      def success?
        success == true
      end
    end

    attr_reader :appointment, :starts_at, :ends_at, :professional

    def initialize(appointment:, starts_at:, ends_at: nil, professional: nil)
      @appointment = appointment
      @professional = professional || appointment.professional
      @starts_at = starts_at.is_a?(String) ? Time.zone.parse(starts_at) : starts_at
      @ends_at = if ends_at.present?
                   ends_at.is_a?(String) ? Time.zone.parse(ends_at) : ends_at
      else
                   @starts_at + appointment.service.duration_minutes.minutes
      end
    end

    def call
      if conflict_checker.has_conflict?
        return Result.new(success: false, appointment: appointment, errors: [ "O novo horário selecionado não está disponível." ])
      end

      appointment.professional = professional
      appointment.starts_at = starts_at
      appointment.ends_at = ends_at
      appointment.status = :pending if appointment.cancelled?

      if appointment.save
        Result.new(success: true, appointment: appointment, errors: [])
      else
        Result.new(success: false, appointment: appointment, errors: appointment.errors.full_messages)
      end
    rescue StandardError => e
      Result.new(success: false, appointment: appointment, errors: [ e.message ])
    end

    private

    def conflict_checker
      Availability::ConflictChecker.new(
        professional: professional,
        starts_at: starts_at,
        ends_at: ends_at,
        ignore_appointment_id: appointment.id
      )
    end
  end
end
