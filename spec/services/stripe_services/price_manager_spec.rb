# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeServices::PriceManager do
  describe '.price_id_for' do
    context 'when environment variables are configured' do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('STRIPE_PRICE_MONTHLY_ID').and_return('price_env_monthly_123')
        allow(ENV).to receive(:[]).with('STRIPE_PRICE_YEARLY_ID').and_return('price_env_yearly_123')
      end

      it 'returns monthly price id from environment' do
        expect(described_class.price_id_for(:monthly)).to eq('price_env_monthly_123')
        expect(described_class.price_id_for('monthly')).to eq('price_env_monthly_123')
      end

      it 'returns yearly price id from environment' do
        expect(described_class.price_id_for(:yearly)).to eq('price_env_yearly_123')
        expect(described_class.price_id_for('yearly')).to eq('price_env_yearly_123')
      end
    end

    context 'when environment variables are not set' do
      before do
        allow(ENV).to receive(:[]).with('STRIPE_PRICE_MONTHLY_ID').and_return(nil)
        allow(ENV).to receive(:[]).with('STRIPE_PRICE_YEARLY_ID').and_return(nil)
      end

      it 'returns a default or resolves price dynamically' do
        price_id = described_class.price_id_for(:monthly)
        expect(price_id).to be_present
      end
    end

    it 'raises ArgumentError for invalid plan interval' do
      expect { described_class.price_id_for(:invalid_plan) }.to raise_error(ArgumentError, /Invalid plan interval/)
    end
  end
end
