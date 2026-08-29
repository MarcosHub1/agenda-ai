class User < ApplicationRecord
  acts_as_tenant :account

  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { owner: 0, admin: 1, professional: 2 }

  validates :email_address, presence: true, uniqueness: { scope: :account_id }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
