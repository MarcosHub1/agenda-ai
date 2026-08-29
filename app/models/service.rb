class Service < ApplicationRecord
  acts_as_tenant :account

  has_many :professional_services, dependent: :destroy
  has_many :professionals, through: :professional_services
  has_many :appointments, dependent: :destroy

  validates :name, presence: true
  validates :duration_minutes, numericality: { greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
end
