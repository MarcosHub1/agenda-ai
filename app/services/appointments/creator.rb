module Appointments
  class Creator
    Result = Struct.new(:success, :appointment, :errors, keyword_init: true) do
      def success?
        success == true
      end
    end

    attr_reader :account, :professional, :service, :starts_at, :ends_at, :client_params, :notes, :metadata

    def initialize(account:, professional:, service:, starts_at:, client_params:, ends_at: nil, notes: nil, metadata: {})
      @account = account
      @professional = professional
      @service = service
      @starts_at = starts_at.is_a?(String) ? Time.zone.parse(starts_at) : starts_at
      @ends_at = (ends_at.presence && (ends_at.is_a?(String) ? Time.zone.parse(ends_at) : ends_at)) || (@starts_at + service.duration_minutes.minutes)
      @client_params = client_params || {}
      @notes = notes
      @metadata = metadata
    end

    def call
      if conflict_checker.has_conflict?
        return Result.new(success: false, errors: [ "O horário selecionado não está mais disponível." ])
      end

      client = find_or_create_client
      unless client.persisted?
        return Result.new(success: false, errors: client.errors.full_messages)
      end

      appointment = Appointment.new(
        account: account,
        professional: professional,
        service: service,
        client: client,
        starts_at: starts_at,
        ends_at: ends_at,
        status: :pending,
        price_cents: service.price_cents,
        notes: notes,
        metadata: metadata
      )

      if appointment.save
        Result.new(success: true, appointment: appointment, errors: [])
      else
        Result.new(success: false, errors: appointment.errors.full_messages)
      end
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success: false, errors: [ e.message ])
    end

    private

    def conflict_checker
      @conflict_checker ||= Availability::ConflictChecker.new(
        professional: professional,
        starts_at: starts_at,
        ends_at: ends_at
      )
    end

    def find_or_create_client
      email = client_params[:email]&.strip&.downcase
      phone = client_params[:phone]&.strip

      client = nil
      client = account.clients.find_by(email: email) if email.present?
      client ||= account.clients.find_by(phone: phone) if phone.present?

      if client
        client.update(name: client_params[:name]) if client_params[:name].present? && client.name.blank?
        client
      else
        account.clients.create(
          name: client_params[:name],
          email: email,
          phone: phone
        )
      end
    end
  end
end
