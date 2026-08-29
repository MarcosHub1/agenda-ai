# frozen_string_literal: true

class SubscriptionPolicy < ApplicationPolicy
  def show?
    owner_or_admin?
  end

  def checkout?
    owner_or_admin?
  end

  def portal?
    owner_or_admin?
  end

  def success?
    owner_or_admin?
  end

  def cancel?
    owner_or_admin?
  end

  private

  def owner_or_admin?
    user.present? && (user.owner? || user.admin?)
  end
end
