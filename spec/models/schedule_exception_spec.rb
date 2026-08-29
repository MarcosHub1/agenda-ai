require 'rails_helper'

RSpec.describe ScheduleException, type: :model do
  let(:account) { Account.create!(name: 'Barbearia Top', slug: 'barbearia-top') }
  let(:pro) { Professional.create!(name: 'Carlos', account: account) }

  it 'is valid with exception date' do
    exc = ScheduleException.new(professional: pro, exception_date: Date.tomorrow, is_blocked: true)
    expect(exc).to be_valid
  end

  it 'is invalid without exception date' do
    exc = ScheduleException.new(professional: pro)
    expect(exc).not_to be_valid
  end
end
