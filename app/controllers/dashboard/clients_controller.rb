# frozen_string_literal: true

module Dashboard
  class ClientsController < BaseController
    before_action :set_client, only: %i[show]

    def index
      @clients = policy_scope(current_tenant.clients).order(:name)

      if params[:query].present?
        query = "%#{params[:query].strip.downcase}%"
        @clients = @clients.where("LOWER(name) LIKE ? OR LOWER(email) LIKE ? OR phone LIKE ?", query, query, query)
      end

      authorize Client
    end

    def show
      authorize @client
      @appointments = @client.appointments.order(starts_at: :desc)
    end

    private

    def set_client
      @client = current_tenant.clients.find(params[:id])
    end
  end
end
