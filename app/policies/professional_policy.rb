# frozen_string_literal: true

class ProfessionalPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    owner_or_admin? || professional_self?
  end

  def create?
    owner_or_admin?
  end

  def new?
    create?
  end

  def update?
    owner_or_admin? || professional_self?
  end

  def edit?
    update?
  end

  def destroy?
    owner_or_admin?
  end

  class Scope < Scope
    def resolve
      if user.owner? || user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def owner_or_admin?
    user.owner? || user.admin?
  end

  def professional_self?
    user.professional? && record.user_id == user.id
  end
end
