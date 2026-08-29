# frozen_string_literal: true

class AppointmentPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owner_or_admin? || professional_owner?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    owner_or_admin? || professional_owner?
  end

  def edit?
    update?
  end

  def destroy?
    owner_or_admin? || professional_owner?
  end

  def confirm?
    update?
  end

  def cancel?
    update?
  end

  def complete?
    update?
  end

  def no_show?
    update?
  end

  class Scope < Scope
    def resolve
      if user.owner? || user.admin?
        scope.all
      else
        scope.joins(:professional).where(professionals: { user_id: user.id })
      end
    end
  end

  private

  def owner_or_admin?
    user.owner? || user.admin?
  end

  def professional_owner?
    user.professional? && record.professional&.user_id == user.id
  end
end
