# frozen_string_literal: true

class ClientPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user.present?
  end

  def edit?
    update?
  end

  def destroy?
    user.owner? || user.admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
