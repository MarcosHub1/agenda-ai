require 'rails_helper'

RSpec.describe Professional, type: :model do
  let(:account) { Account.create!(name: 'Barbearia Top', slug: 'barbearia-top') }
  let(:other_account) { Account.create!(name: 'Clinica Boa', slug: 'clinica-boa') }

  before do
    ActsAsTenant.current_tenant = account
  end

  after do
    ActsAsTenant.current_tenant = nil
  end

  describe 'validations' do
    it 'is valid with name' do
      pro = Professional.new(name: 'Carlos Barbeiro', account: account)
      expect(pro).to be_valid
    end

    it 'is invalid without name' do
      pro = Professional.new(account: account)
      expect(pro).not_to be_valid
      expect(pro.errors[:name]).to be_present
    end
  end

  describe 'multi-tenant scoping' do
    it 'only returns records belonging to current tenant' do
      pro1 = Professional.create!(name: 'Pro Account 1', account: account)

      ActsAsTenant.with_tenant(other_account) do
        Professional.create!(name: 'Pro Account 2', account: other_account)
        expect(Professional.all).not_to include(pro1)
      end

      expect(Professional.all).to include(pro1)
    end
  end
end
