# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder CustomFormBuilder
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  around_action :set_locale
  before_action :configure_permitted_params, if: :devise_controller?
  before_action :check_device_approval
  before_action :check_ip

  def after_sign_in_path_for(resource)
    session[:login_date] = Date.current.ajd.to_i
    super
  end

  private

  def check_device_approval
    return unless user_signed_in?
    return unless current_user.roles_needing_device_approval?
    return if current_user.devices.approved.exists?(token: device_token)

    current_user.devices.find_or_create_by!(token: device_token) do |d|
      d.user_agent = request.user_agent
      d.platform = request.env["HTTP_SEC_CH_UA_PLATFORM"]
      d.ip_address = request.remote_ip
      d.status = :pending
    end

    if Rails.configuration.x.device_lock_enforced
      redirect_to pending_device_path
    end
  end

  def check_ip
    return unless needs_ip_check?
    return if current_user.allowed_ip?(request.ip)

    rejected_user = current_user
    sign_out
    redirect_to after_sign_out_path_for(rejected_user),
                alert: I18n.t('not_in_school')
  end

  def device_token
    @device_token ||= begin
    token = params[:device_token] || cookies[:device_token]
    token.presence || "unknown"
    end
  end
  
  def needs_ip_check?
    current_user&.ku? &&
      current_user&.is?('SchoolManager', 'Teacher')
  end

  def authorized_ku_staff?
    current_user.is?('Admin', 'Sales')
  end
  
  def configure_permitted_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name organisation_id])
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def set_locale(&)
    locale = params[:locale] || locale_from_accept_language || I18n.default_locale
    I18n.with_locale(locale, &)
  end

  def locale_from_accept_language
    http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def reset_daily_login
    return unless current_user && session[:login_date]

    return unless session[:login_date] < Date.current.ajd.to_i

    sign_out(current_user)
    redirect_to new_user_session_path, notice: t('not_authorized') and return
  end

  def user_not_authorized
    redirect_to root_path,
                alert: t('not_authorized')
  end
end
