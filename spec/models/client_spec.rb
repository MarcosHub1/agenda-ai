require 'rails_helper'

RSpec.describe Client, type: :model do
  let(:account) { Account.create!(name: 'Barbearia Top', slug: 'barbearia-top') }

  before do
    ActsAsTenant.current_tenant = account
  end

  after do
    ActsAsTenant.current_tenant = nil
  end

  it 'is valid with name and phone' do
    client = Client.new(account: account, name: 'Maria', phone: '1199999999')
    expect(client).to be_valid
  end

  it 'is invalid without both email and phone' do
    client = Client.new(account: account, name: 'Maria')
    expect(client).not_to be_valid
  end
end
