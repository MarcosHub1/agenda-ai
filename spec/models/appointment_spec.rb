require 'rails_helper'

RSpec.describe Appointment, type: :model do
  let(:account) { Account.create!(name: 'Barbearia Top', slug: 'barbearia-top') }
  let(:pro) { Professional.create!(name: 'Carlos', account: account) }
  let(:service) { Service.create!(name: 'Corte', duration_minutes: 30, price_cents: 5000, account: account) }
  let(:client) { Client.create!(name: 'João', email: 'joao@example.com', account: account) }

  before do
    ActsAsTenant.current_tenant = account
  end

  after do
    ActsAsTenant.current_tenant = nil
  end

  it 'is valid with valid starts_at and ends_at' do
    appointment = Appointment.new(
      account: account,
      professional: pro,
      service: service,
      client: client,
      starts_at: Time.current + 1.hour,
      ends_at: Time.current + 1.hour + 30.minutes,
      status: :pending
    )
    expect(appointment).to be_valid
  end

  it 'is invalid if starts_at is after ends_at' do
    appointment = Appointment.new(
      account: account,
      professional: pro,
      service: service,
      client: client,
      starts_at: Time.current + 2.hours,
      ends_at: Time.current + 1.hour,
      status: :pending
    )
    expect(appointment).not_to be_valid
    expect(appointment.errors[:starts_at]).to be_present
  end
end
