require 'rails_helper'

RSpec.describe Appointments::Creator do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-creator-test') }
  let(:pro) { Professional.create!(account: account, name: 'Carlos', email: 'carlos@test.com') }
  let(:service) { Service.create!(account: account, name: 'Corte', duration_minutes: 30, price_cents: 5000) }

  let(:starts_at) { Time.current + 1.day }
  let(:client_params) { { name: 'João Silva', email: 'joao@example.com', phone: '(11) 99999-8888' } }

  before do
    ActsAsTenant.current_tenant = account
  end

  after do
    ActsAsTenant.current_tenant = nil
  end

  describe '#call' do
    context 'when slot is available and client data is valid' do
      it 'creates the client and appointment successfully' do
        result = described_class.new(
          account: account,
          professional: pro,
          service: service,
          starts_at: starts_at,
          client_params: client_params,
          notes: 'Preferência por tesoura'
        ).call

        expect(result.success?).to be true
        expect(result.appointment).to be_persisted
        expect(result.appointment.client.name).to eq('João Silva')
        expect(result.appointment.status).to eq('pending')
        expect(result.appointment.price_cents).to eq(5000)
        expect(result.appointment.ends_at).to be_within(1.second).of(starts_at + 30.minutes)
      end
    end

    context 'when the client already exists in this tenant' do
      let!(:existing_client) do
        Client.create!(account: account, name: 'João Existente', email: 'joao@example.com', phone: '(11) 99999-8888')
      end

      it 'reuses the existing client' do
        result = described_class.new(
          account: account,
          professional: pro,
          service: service,
          starts_at: starts_at,
          client_params: client_params
        ).call

        expect(result.success?).to be true
        expect(result.appointment.client_id).to eq(existing_client.id)
      end
    end

    context 'when there is a time conflict' do
      before do
        client = Client.create!(account: account, name: 'Outro', email: 'outro@test.com')
        Appointment.create!(
          account: account,
          professional: pro,
          service: service,
          client: client,
          starts_at: starts_at,
          ends_at: starts_at + 30.minutes,
          status: :confirmed
        )
      end

      it 'fails and does not create an overlapping appointment' do
        result = described_class.new(
          account: account,
          professional: pro,
          service: service,
          starts_at: starts_at,
          client_params: client_params
        ).call

        expect(result.success?).to be false
        expect(result.errors).to include('O horário selecionado não está mais disponível.')
      end
    end
  end
end
