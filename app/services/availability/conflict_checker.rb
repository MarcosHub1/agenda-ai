module Availability
  class ConflictChecker
    attr_reader :professional, :starts_at, :ends_at, :ignore_appointment_id

    def initialize(professional:, starts_at:, ends_at:, ignore_appointment_id: nil)
      @professional = professional
      @starts_at = starts_at
      @ends_at = ends_at
      @ignore_appointment_id = ignore_appointment_id
    end

    def has_conflict?
      blocked_by_exception? || overlapping_appointment?
    end

    private

    def blocked_by_exception?
      date = starts_at.to_date
      exceptions = professional.schedule_exceptions.where(exception_date: date)

      exceptions.any? do |exc|
        if exc.is_blocked?
          true
        elsif exc.start_time.present? && exc.end_time.present?
          exc_start = Time.zone.parse("#{date} #{exc.start_time.strftime('%H:%M:%S')}")
          exc_end = Time.zone.parse("#{date} #{exc.end_time.strftime('%H:%M:%S')}")
          starts_at < exc_start || ends_at > exc_end
        else
          false
        end
      end
    end

    def overlapping_appointment?
      scope = professional.appointments
                          .where(status: [ :pending, :confirmed ])
                          .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)

      scope = scope.where.not(id: ignore_appointment_id) if ignore_appointment_id.present?
      scope.exists?
    end
  end
end
