module Availability
  class SlotCalculator
    attr_reader :professional, :service, :date, :account

    def initialize(professional:, service:, date:)
      @professional = professional
      @service = service
      @date = date.is_a?(String) ? Date.parse(date) : date
      @account = professional.account
    end

    def call
      return [] if date_out_of_bounds?

      exception = professional.schedule_exceptions.find_by(exception_date: date)
      return [] if exception&.is_blocked?

      schedule = professional.work_schedules.find_by(day_of_week: date.wday, enabled: true)
      return [] if schedule.nil? && exception.nil?

      tz = Time.find_zone(account&.timezone.presence || "UTC")

      start_time_obj = exception&.start_time || schedule&.start_time
      end_time_obj = exception&.end_time || schedule&.end_time
      return [] if start_time_obj.blank? || end_time_obj.blank?

      day_start = tz.local(date.year, date.month, date.day, start_time_obj.hour, start_time_obj.min)
      day_end = tz.local(date.year, date.month, date.day, end_time_obj.hour, end_time_obj.min)

      break_start = nil
      break_end = nil
      if schedule&.break_start.present? && schedule&.break_end.present?
        break_start = tz.local(date.year, date.month, date.day, schedule.break_start.hour, schedule.break_start.min)
        break_end = tz.local(date.year, date.month, date.day, schedule.break_end.hour, schedule.break_end.min)
      end

      generate_slots(day_start, day_end, break_start, break_end, tz)
    end

    private

    def date_out_of_bounds?
      today = Date.current
      max_days = account_setting("max_advance_days", 30).to_i
      date < today || date > (today + max_days.days)
    end

    def generate_slots(day_start, day_end, break_start, break_end, tz)
      slots = []
      duration = service.duration_minutes.minutes
      buffer = account_setting("slot_buffer_minutes", 0).to_i.minutes
      step = duration + buffer

      min_advance_hours = account_setting("min_advance_hours", 2).to_i
      min_time_allowed = Time.current.in_time_zone(tz) + min_advance_hours.hours

      # Load all active appointments for the professional on this date once
      existing_appointments = professional.appointments
                                          .where(status: [ :pending, :confirmed ])
                                          .where("starts_at >= ? AND starts_at < ?", day_start.beginning_of_day, day_start.end_of_day)
                                          .pluck(:starts_at, :ends_at)

      current_start = day_start

      while (current_start + duration) <= day_end
        current_end = current_start + duration

        # Check if slot overlaps with break
        in_break = false
        if break_start && break_end
          in_break = (current_start < break_end && current_end > break_start)
        end

        unless in_break
          is_past_min_advance = current_start < min_time_allowed

          has_overlap = existing_appointments.any? do |appt_start, appt_end|
            current_start < appt_end && current_end > appt_start
          end

          is_available = !is_past_min_advance && !has_overlap

          slots << {
            starts_at: current_start,
            ends_at: current_end,
            available: is_available
          }
        end

        current_start += step
      end

      slots
    end

    def account_setting(key, default)
      account&.settings&.dig(key) || account&.settings&.dig(key.to_s) || default
    end
  end
end
