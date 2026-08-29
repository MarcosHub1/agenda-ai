class Professional < ApplicationRecord
  acts_as_tenant :account

  belongs_to :user, optional: true
  has_many :professional_services, dependent: :destroy
  has_many :services, through: :professional_services
  has_many :work_schedules, dependent: :destroy
  has_many :schedule_exceptions, dependent: :destroy
  has_many :appointments, dependent: :destroy

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
