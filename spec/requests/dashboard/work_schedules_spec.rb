# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard Work Schedules', type: :request do
  let(:account) { Account.create!(name: 'Barbearia Navalha', slug: 'navalha-ws-spec') }
  let(:user) { User.create!(account: account, email_address: 'admin@navalha.com', password: 'password123', role: :owner) }
  let(:pro) { Professional.create!(account: account, name: 'Lucas', email: 'lucas@test.com') }
  let!(:schedule) do
    pro.work_schedules.create!(
      day_of_week: :monday,
      start_time: '09:00',
      end_time: '18:00',
      enabled: true
    )
  end

  before do
    sign_in_user(user)
  end

  describe 'PATCH /dashboard/professionals/:professional_id/work_schedules/:id' do
    it 'updates start and end times' do
      patch dashboard_professional_work_schedule_path(pro, schedule), params: {
        work_schedule: {
          start_time: '08:00',
          end_time: '17:00'
        }
      }

      expect(response).to redirect_to(dashboard_professional_path(pro))
      expect(schedule.reload.start_time.strftime('%H:%M')).to eq('08:00')
      expect(schedule.end_time.strftime('%H:%M')).to eq('17:00')
    end
  end
end
