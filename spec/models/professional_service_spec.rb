require 'rails_helper'

RSpec.describe ProfessionalService, type: :model do
  let(:account) { Account.create!(name: 'Barbearia Top', slug: 'barbearia-top') }
  let(:pro) { Professional.create!(name: 'Carlos', account: account) }
  let(:service) { Service.create!(name: 'Corte', duration_minutes: 30, price_cents: 5000, account: account) }

  it 'validates uniqueness of professional scoped to service' do
    ProfessionalService.create!(professional: pro, service: service)
    duplicate = ProfessionalService.new(professional: pro, service: service)
    expect(duplicate).not_to be_valid
  end
end
