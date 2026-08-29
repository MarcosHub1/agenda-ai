class ScheduleException < ApplicationRecord
  belongs_to :professional

  validates :exception_date, presence: true
end
