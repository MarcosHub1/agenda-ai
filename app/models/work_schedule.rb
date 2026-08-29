class WorkSchedule < ApplicationRecord
  belongs_to :professional

  enum :day_of_week, { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }

  validates :day_of_week, presence: true, uniqueness: { scope: :professional_id }
  validates :start_time, :end_time, presence: true
  validate :start_time_before_end_time

  private

  def start_time_before_end_time
    return if start_time.blank? || end_time.blank?

    errors.add(:start_time, "deve ser anterior ao horário de término") if start_time >= end_time
  end
end
