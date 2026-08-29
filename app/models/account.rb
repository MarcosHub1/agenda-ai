class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :professionals, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_one :subscription, dependent: :destroy

  enum :status, { active: 0, suspended: 1, cancelled: 2 }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "deve conter apenas letras minúsculas, números e hífens" }

  def active_subscription?
    subscription&.active_or_trialing? || false
  end

  def subscribed?
    subscription&.active? || false
  end
end
