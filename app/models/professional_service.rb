class ProfessionalService < ApplicationRecord
  belongs_to :professional
  belongs_to :service

  validates :professional_id, uniqueness: { scope: :service_id }
end
