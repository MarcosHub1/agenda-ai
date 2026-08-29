class Client < ApplicationRecord
  acts_as_tenant :account

  has_many :appointments, dependent: :destroy

  validates :name, presence: true
  validate :email_or_phone_present

  private

  def email_or_phone_present
    return if email.present? || phone.present?

    errors.add(:base, "Informe pelo menos um e-mail ou telefone de contato")
  end
end
