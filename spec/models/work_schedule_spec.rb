require 'rails_helper'

RSpec.describe WorkSchedule, type: :model do
  let(:account) { Account.create!(name: 'Barbearia Top', slug: 'barbearia-top') }
  let(:pro) { Professional.create!(name: 'Carlos', account: account) }

  it 'is valid with start and end times' do
    ws = WorkSchedule.new(
      professional: pro,
      day_of_week: :monday,
      start_time: '09:00',
      end_time: '18:00'
    )
    expect(ws).to be_valid
  end

  it 'is invalid if start_time is after end_time' do
    ws = WorkSchedule.new(
      professional: pro,
      day_of_week: :monday,
      start_time: '19:00',
      end_time: '18:00'
    )
    expect(ws).not_to be_valid
    expect(ws.errors[:start_time]).to be_present
  end
end
