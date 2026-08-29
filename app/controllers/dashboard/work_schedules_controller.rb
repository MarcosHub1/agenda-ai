# frozen_string_literal: true

module Dashboard
  class WorkSchedulesController < BaseController
    before_action :set_professional
    before_action :set_work_schedule, only: %i[update]

    def index
      @work_schedules = @professional.work_schedules.order(:day_of_week)
      authorize WorkSchedule
    end

    def update
      authorize @work_schedule

      if @work_schedule.update(work_schedule_params)
        redirect_to dashboard_professional_path(@professional), notice: "Horário de trabalho atualizado com sucesso."
      else
        @work_schedules = @professional.work_schedules.order(:day_of_week)
        render :index, status: :unprocessable_entity
      end
    end

    private

    def set_professional
      @professional = current_tenant.professionals.find(params[:professional_id])
    end

    def set_work_schedule
      @work_schedule = @professional.work_schedules.find(params[:id])
    end

    def work_schedule_params
      params.require(:work_schedule).permit(:start_time, :end_time, :break_start, :break_end, :enabled)
    end
  end
end
