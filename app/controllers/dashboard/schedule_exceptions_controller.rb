# frozen_string_literal: true

module Dashboard
  class ScheduleExceptionsController < BaseController
    before_action :set_professional
    before_action :set_schedule_exception, only: %i[destroy]

    def index
      @schedule_exceptions = @professional.schedule_exceptions.order(:exception_date)
      @new_exception = @professional.schedule_exceptions.build(exception_date: Date.tomorrow)
      authorize ScheduleException
    end

    def create
      @schedule_exception = @professional.schedule_exceptions.build(schedule_exception_params)
      authorize @schedule_exception

      if @schedule_exception.save
        redirect_to dashboard_professional_schedule_exceptions_path(@professional), notice: "Exceção/Folga adicionada com sucesso."
      else
        @schedule_exceptions = @professional.schedule_exceptions.order(:exception_date)
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @schedule_exception
      @schedule_exception.destroy
      redirect_to dashboard_professional_schedule_exceptions_path(@professional), notice: "Exceção removida com sucesso."
    end

    private

    def set_professional
      @professional = current_tenant.professionals.find(params[:professional_id])
    end

    def set_schedule_exception
      @schedule_exception = @professional.schedule_exceptions.find(params[:id])
    end

    def schedule_exception_params
      params.require(:schedule_exception).permit(:exception_date, :is_blocked, :start_time, :end_time, :reason)
    end
  end
end
