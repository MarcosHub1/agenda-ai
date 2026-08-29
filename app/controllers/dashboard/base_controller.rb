# frozen_string_literal: true

module Dashboard
  class BaseController < ApplicationController
    layout "dashboard"

    before_action :ensure_authenticated_tenant!
    before_action :ensure_active_subscription!

    private

    def ensure_authenticated_tenant!
      unless authenticated?
        request_authentication
        return
      end

      set_current_tenant(Current.session.user.account)
    end

    def ensure_active_subscription!
      return if controller_name == "billing"

      unless current_tenant&.active_subscription?
        redirect_to dashboard_billing_path, alert: "Você precisa de uma assinatura ativa para acessar os recursos da plataforma. Escolha um plano abaixo para começar."
      end
    end
  end
end
