require 'rails_helper'

RSpec.describe Service, type: :model do
  let(:account) { Account.create!(name: 'Barbearia Top', slug: 'barbearia-top') }

  before do
    ActsAsTenant.current_tenant = account
  end

  after do
    ActsAsTenant.current_tenant = nil
  end

  it 'is valid with name, duration and price' do
    service = Service.new(account: account, name: 'Corte', duration_minutes: 30, price_cents: 3500)
    expect(service).to be_valid
  end

  it 'is invalid with non-positive duration' do
    service = Service.new(account: account, name: 'Corte', duration_minutes: 0, price_cents: 3500)
    expect(service).not_to be_valid
  end
end
