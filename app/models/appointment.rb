class Appointment < ApplicationRecord
  acts_as_tenant :account

  belongs_to :professional
  belongs_to :service
  belongs_to :client

  enum :status, { pending: 0, confirmed: 1, completed: 2, cancelled: 3, no_show: 4 }

  validates :starts_at, :ends_at, presence: true
  validate :starts_at_before_ends_at

  private

  def starts_at_before_ends_at
    return if starts_at.blank? || ends_at.blank?

    errors.add(:starts_at, "deve ser anterior ao horário de término") if starts_at >= ends_at
  end
end
