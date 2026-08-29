# frozen_string_literal: true

module Dashboard
  class ServicesController < BaseController
    before_action :set_service, only: %i[show edit update destroy]

    def index
      @services = policy_scope(current_tenant.services).order(:sort_order, :name)
      authorize Service
    end

    def show
      authorize @service
      @professionals = @service.professionals.order(:name)
    end

    def new
      @service = current_tenant.services.build(duration_minutes: 30, price_cents: 5000, currency: "BRL")
      authorize @service
      @professionals = current_tenant.professionals.where(active: true).order(:name)
    end

    def create
      @service = current_tenant.services.build(service_params)
      authorize @service

      if @service.save
        if params[:service][:professional_ids].present?
          @service.professional_ids = params[:service][:professional_ids].reject(&:blank?)
        end

        redirect_to dashboard_services_path, notice: "Serviço criado com sucesso."
      else
        @professionals = current_tenant.professionals.where(active: true).order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @service
      @professionals = current_tenant.professionals.where(active: true).order(:name)
    end

    def update
      authorize @service

      if @service.update(service_params)
        if params[:service][:professional_ids].present?
          @service.professional_ids = params[:service][:professional_ids].reject(&:blank?)
        end

        redirect_to dashboard_services_path, notice: "Serviço atualizado com sucesso."
      else
        @professionals = current_tenant.professionals.where(active: true).order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @service
      @service.destroy
      redirect_to dashboard_services_path, notice: "Serviço removido com sucesso."
    end

    private

    def set_service
      @service = current_tenant.services.find(params[:id])
    end

    def service_params
      # Note: price in form can be submitted as price in reais (e.g. 50.00) or price_cents directly.
      permitted = params.require(:service).permit(:name, :description, :duration_minutes, :price_cents, :price, :currency, :active, :sort_order)
      if permitted[:price].present?
        # Convert float/string real value to cents
        permitted[:price_cents] = (permitted[:price].to_s.tr(",", ".").to_f * 100).round
        permitted.delete(:price)
      end
      permitted
    end
  end
end
