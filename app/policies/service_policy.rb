# frozen_string_literal: true

class ServicePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    owner_or_admin?
  end

  def new?
    create?
  end

  def update?
    owner_or_admin?
  end

  def edit?
    update?
  end

  def destroy?
    owner_or_admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def owner_or_admin?
    user.owner? || user.admin?
  end
end
