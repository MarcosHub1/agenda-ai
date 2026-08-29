# frozen_string_literal: true

module Dashboard
  class ProfessionalsController < BaseController
    before_action :set_professional, only: %i[show edit update destroy]

    def index
      @professionals = policy_scope(current_tenant.professionals).order(:name)
      authorize Professional
    end

    def show
      authorize @professional
      @work_schedules = @professional.work_schedules.order(:day_of_week)
      @schedule_exceptions = @professional.schedule_exceptions.where("exception_date >= ?", Date.current).order(:exception_date)
      @services = @professional.services
    end

    def new
      @professional = current_tenant.professionals.build
      authorize @professional
      @services = current_tenant.services.where(active: true).order(:name)
    end

    def create
      @professional = current_tenant.professionals.build(professional_params)
      authorize @professional

      if @professional.save
        # Assign selected services if provided
        if params[:professional][:service_ids].present?
          @professional.service_ids = params[:professional][:service_ids].reject(&:blank?)
        end

        # Create default work schedule (Mon-Fri, 09:00 - 18:00, lunch 12:00-13:00) if none exists
        create_default_work_schedules(@professional)

        redirect_to dashboard_professional_path(@professional), notice: "Profissional cadastrado com sucesso."
      else
        @services = current_tenant.services.where(active: true).order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @professional
      @services = current_tenant.services.where(active: true).order(:name)
    end

    def update
      authorize @professional

      if @professional.update(professional_params)
        if params[:professional][:service_ids].present?
          @professional.service_ids = params[:professional][:service_ids].reject(&:blank?)
        end

        redirect_to dashboard_professional_path(@professional), notice: "Profissional atualizado com sucesso."
      else
        @services = current_tenant.services.where(active: true).order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @professional
      @professional.destroy
      redirect_to dashboard_professionals_path, notice: "Profissional removido com sucesso."
    end

    private

    def set_professional
      @professional = current_tenant.professionals.find(params[:id])
    end

    def professional_params
      params.require(:professional).permit(:name, :email, :avatar_url, :active, :user_id)
    end

    def create_default_work_schedules(professional)
      return if professional.work_schedules.exists?

      WorkSchedule.day_of_weeks.each_value do |day_val|
        is_weekday = (1..5).cover?(day_val)
        professional.work_schedules.create!(
          day_of_week: day_val,
          start_time: "09:00",
          end_time: "18:00",
          break_start: "12:00",
          break_end: "13:00",
          enabled: is_weekday
        )
      end
    end
  end
end
