# frozen_string_literal: true

class ScheduleExceptionPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owner_or_admin? || professional_owner?
  end

  def create?
    owner_or_admin? || professional_owner?
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

  private

  def owner_or_admin?
    user.owner? || user.admin?
  end

  def professional_owner?
    user.professional? && record.professional&.user_id == user.id
  end
end
