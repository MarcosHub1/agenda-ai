require 'rails_helper'

RSpec.describe User, type: :model do
  let(:account) { Account.create!(name: 'Barbearia Top', slug: 'barbearia-top') }

  before do
    ActsAsTenant.current_tenant = account
  end

  after do
    ActsAsTenant.current_tenant = nil
  end

  it 'authenticates with valid password' do
    user = User.create!(
      account: account,
      name: 'Carlos Owner',
      email_address: 'owner@top.com',
      password: 'password123',
      role: :owner
    )
    expect(user.authenticate('password123')).to eq(user)
    expect(user.authenticate('wrong')).to be_falsey
  end

  it 'scopes email uniqueness per account' do
    User.create!(account: account, name: 'User 1', email_address: 'test@example.com', password: 'password123')
    duplicate = User.new(account: account, name: 'User 2', email_address: 'test@example.com', password: 'password123')
    expect(duplicate).not_to be_valid
  end
end
