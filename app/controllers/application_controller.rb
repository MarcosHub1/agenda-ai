class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  set_current_tenant_through_filter
  before_action :set_tenant

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def current_user
    Current.session&.user
  end
  helper_method :current_user

  def pundit_user
    current_user
  end

  private

  def set_tenant
    tenant =
      if params[:tenant_slug].present?
        Account.find_by(slug: params[:tenant_slug])
      elsif Current.session&.user&.account.present?
        Current.session.user.account
      elsif request.subdomain.present? && request.subdomain != "www"
        Account.find_by(slug: request.subdomain)
      end

    set_current_tenant(tenant) if tenant
  end
end
