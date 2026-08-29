require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      account = Account.new(name: 'Barbearia Top', slug: 'barbearia-top')
      expect(account).to be_valid
    end

    it 'is invalid without a name' do
      account = Account.new(slug: 'barbearia-top')
      expect(account).not_to be_valid
      expect(account.errors[:name]).to be_present
    end

    it 'is invalid without a slug' do
      account = Account.new(name: 'Barbearia Top')
      expect(account).not_to be_valid
      expect(account.errors[:slug]).to be_present
    end

    it 'is invalid with duplicate slug' do
      Account.create!(name: 'Barbearia 1', slug: 'barbearia')
      duplicate = Account.new(name: 'Barbearia 2', slug: 'barbearia')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to be_present
    end
  end

  describe 'subscription helpers' do
    let(:account) { Account.create!(name: 'Barbearia Teste', slug: 'barbearia-teste') }

    it 'returns false when account has no subscription' do
      expect(account.active_subscription?).to be false
      expect(account.subscribed?).to be false
    end

    it 'returns true for active_subscription? when subscription is active' do
      Subscription.create!(account: account, plan_interval: :monthly, status: :active)
      expect(account.active_subscription?).to be true
      expect(account.subscribed?).to be true
    end

    it 'returns true for active_subscription? and false for subscribed? when trialing' do
      Subscription.create!(account: account, plan_interval: :monthly, status: :trialing)
      expect(account.active_subscription?).to be true
      expect(account.subscribed?).to be false
    end
  end
end
