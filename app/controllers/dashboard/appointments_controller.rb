# frozen_string_literal: true

module Dashboard
  class AppointmentsController < BaseController
    before_action :set_appointment, only: %i[show edit update destroy confirm cancel complete no_show]

    def index
      @appointments = policy_scope(current_tenant.appointments).includes(:professional, :service, :client)

      # Filter by status if provided
      if params[:status].present? && Appointment.statuses.key?(params[:status])
        @appointments = @appointments.where(status: params[:status])
      end

      # Filter by professional if provided
      if params[:professional_id].present?
        @appointments = @appointments.where(professional_id: params[:professional_id])
      end

      # Filter by date range or specific date
      if params[:date].present?
        selected_date = Date.parse(params[:date]) rescue Date.current
        @appointments = @appointments.where("starts_at >= ? AND starts_at <= ?", selected_date.beginning_of_day, selected_date.end_of_day)
      elsif params[:view] == "upcoming"
        @appointments = @appointments.where("starts_at >= ?", Time.current)
      end

      @appointments = @appointments.order(starts_at: :desc).limit(50)
      @professionals = current_tenant.professionals.order(:name)
      authorize Appointment
    end

    def show
      authorize @appointment
    end

    def new
      @appointment = current_tenant.appointments.build(
        starts_at: Time.current.beginning_of_hour + 1.hour,
        status: :confirmed
      )
      authorize @appointment
      load_form_collections
    end

    def create
      authorize Appointment

      professional = current_tenant.professionals.find(appointment_params[:professional_id])
      service = current_tenant.services.find(appointment_params[:service_id])

      client_params = {
        name: params.dig(:appointment, :client_name),
        email: params.dig(:appointment, :client_email),
        phone: params.dig(:appointment, :client_phone)
      }

      result = Appointments::Creator.new(
        account: current_tenant,
        professional: professional,
        service: service,
        starts_at: appointment_params[:starts_at],
        client_params: client_params,
        notes: appointment_params[:notes]
      ).call

      if result.success?
        @appointment = result.appointment
        @appointment.update(status: appointment_params[:status]) if appointment_params[:status].present?
        redirect_to dashboard_appointment_path(@appointment), notice: "Agendamento criado com sucesso."
      else
        @appointment = current_tenant.appointments.build(appointment_params)
        @client_name = client_params[:name]
        @client_email = client_params[:email]
        @client_phone = client_params[:phone]
        flash.now[:alert] = result.errors.join(", ")
        load_form_collections
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @appointment
      load_form_collections
    end

    def update
      authorize @appointment

      new_starts_at = appointment_params[:starts_at]
      new_pro_id = appointment_params[:professional_id]
      new_pro = current_tenant.professionals.find_by(id: new_pro_id) || @appointment.professional

      if new_starts_at.present? && (Time.zone.parse(new_starts_at) != @appointment.starts_at || new_pro != @appointment.professional)
        reschedule_result = Appointments::Rescheduler.new(
          appointment: @appointment,
          starts_at: new_starts_at,
          professional: new_pro
        ).call

        unless reschedule_result.success?
          flash.now[:alert] = reschedule_result.errors.join(", ")
          load_form_collections
          render :edit, status: :unprocessable_entity and return
        end
      end

      if @appointment.update(appointment_params.except(:starts_at, :professional_id))
        redirect_to dashboard_appointment_path(@appointment), notice: "Agendamento atualizado com sucesso."
      else
        load_form_collections
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @appointment
      @appointment.destroy
      redirect_to dashboard_appointments_path, notice: "Agendamento excluído com sucesso."
    end

    def confirm
      authorize @appointment
      @appointment.update(status: :confirmed)
      redirect_back fallback_location: dashboard_appointments_path, notice: "Agendamento confirmado."
    end

    def cancel
      authorize @appointment
      reason = params[:cancellation_reason].presence || "Cancelado pelo administrador"
      result = Appointments::Canceller.new(appointment: @appointment, reason: reason).call

      if result.success?
        redirect_back fallback_location: dashboard_appointments_path, notice: "Agendamento cancelado."
      else
        redirect_back fallback_location: dashboard_appointments_path, alert: result.errors.join(", ")
      end
    end

    def complete
      authorize @appointment
      @appointment.update(status: :completed)
      redirect_back fallback_location: dashboard_appointments_path, notice: "Agendamento marcado como concluído."
    end

    def no_show
      authorize @appointment
      @appointment.update(status: :no_show)
      redirect_back fallback_location: dashboard_appointments_path, notice: "Agendamento marcado como não compareceu."
    end

    private

    def set_appointment
      @appointment = current_tenant.appointments.find(params[:id])
    end

    def load_form_collections
      @professionals = current_tenant.professionals.where(active: true).order(:name)
      @services = current_tenant.services.where(active: true).order(:name)
    end

    def appointment_params
      params.require(:appointment).permit(:professional_id, :service_id, :starts_at, :status, :notes, :cancellation_reason)
    end
  end
end
