# frozen_string_literal: true

module Dashboard
  class SettingsController < BaseController
    before_action :set_account

    def show
      authorize @account
    end

    def edit
      authorize @account
    end

    def update
      authorize @account

      new_settings = (@account.settings || {}).merge(
        "slot_buffer_minutes" => params.dig(:account, :settings, :slot_buffer_minutes).to_i,
        "min_advance_hours" => params.dig(:account, :settings, :min_advance_hours).to_i,
        "max_advance_days" => params.dig(:account, :settings, :max_advance_days).to_i
      )

      @account.settings = new_settings

      if @account.update(account_params)
        redirect_to dashboard_settings_path, notice: "Configurações atualizadas com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_account
      @account = current_tenant
    end

    def account_params
      params.require(:account).permit(:name, :timezone, :currency, :logo_url)
    end
  end
end
