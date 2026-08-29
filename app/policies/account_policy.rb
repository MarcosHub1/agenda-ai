# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  def show?
    owner_or_admin?
  end

  def update?
    owner_or_admin?
  end

  def edit?
    update?
  end

  private

  def owner_or_admin?
    user.present? && (user.owner? || user.admin?)
  end
end
