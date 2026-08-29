# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Schedule Exceptions', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-se-spec') }
  let(:user) { User.create!(account: account, email_address: 'admin@navalha.com', password: 'password123', role: :owner) }
  let(:pro) { Professional.create!(account: account, name: 'Lucas', email: 'lucas@test.com') }

  before do
    sign_in_user(user)
  end

  describe 'POST /dashboard/professionals/:professional_id/schedule_exceptions' do
    it 'creates a blocked day exception' do
      expect do
        post dashboard_professional_schedule_exceptions_path(pro), params: {
          schedule_exception: {
            exception_date: Date.tomorrow,
            is_blocked: true,
            reason: 'Feriado Municipal'
          }
        }
      end.to change(pro.schedule_exceptions, :count).by(1)

      expect(response).to redirect_to(dashboard_professional_schedule_exceptions_path(pro))
      expect(pro.schedule_exceptions.last.reason).to eq('Feriado Municipal')
    end
  end

  describe 'DELETE /dashboard/professionals/:professional_id/schedule_exceptions/:id' do
    it 'removes an exception' do
      exc = pro.schedule_exceptions.create!(exception_date: Date.tomorrow, is_blocked: true)

      expect do
        delete dashboard_professional_schedule_exception_path(pro, exc)
      end.to change(pro.schedule_exceptions, :count).by(-1)

      expect(response).to redirect_to(dashboard_professional_schedule_exceptions_path(pro))
    end
  end
end
