# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder CustomFormBuilder
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  around_action :set_locale
  before_action :configure_permitted_params, if: :devise_controller?
  # before_action :ensure_privacy_policy_accepted
  before_action :ensure_device_record, unless: -> { logging_out? }
  before_action :enforce_device_approval, if: -> { Rails.configuration.x.device_lock_enforced },
                                          unless: -> { logging_out? || on_pending_device_page? }
  before_action :check_ip

  def after_sign_in_path_for(resource)
    session[:login_date] = Date.current.ajd.to_i
    super
  end

  private

  def ensure_device_record
    return unless user_signed_in?
    return unless current_user.roles_needing_device_approval?

    tok = device_token
    device = current_user.devices.find_or_initialize_by(token: tok)
    device.user_agent ||= request.user_agent
    device.platform   ||= request.env['HTTP_SEC_CH_UA_PLATFORM']
    device.ip_address = request.remote_ip if device.ip_address.blank?
    device.status   ||= :pending
    device.save! if device.changed?
  end

  def enforce_device_approval
    return unless user_signed_in?
    return unless current_user.roles_needing_device_approval?

    device = current_user.devices.find_by(token: device_token)
    return if device&.approved?

    redirect_to pending_device_path
  end

  def on_pending_device_page?
    request.path == pending_device_path
  end

  def check_ip
    return unless needs_ip_check?
    return if current_user.allowed_ip?(request.ip)

    rejected_user = current_user
    sign_out
    redirect_to after_sign_out_path_for(rejected_user),
                alert: I18n.t('not_in_school')
  end

  def ensure_privacy_policy_accepted
    return unless user_signed_in?

    latest_id = PrivacyPolicy.latest_id
    accepted = current_user.privacy_policy_acceptances
                           .exists?(privacy_policy_id: latest_id)
    return if accepted

    store_location_for(:user, request.fullpath)

    redirect_to new_privacy_policy_acceptance_path
  end

  def device_token
    @device_token ||= begin
      token = params[:device_token].presence || cookies.signed[:device_token]
      if token.blank?
        token = SecureRandom.uuid
        cookies.signed[:device_token] = {
          value: token,
          expires: 10.years.from_now,
          httponly: true,
          same_site: :lax,
          secure: Rails.env.production?
        }
      end
      token
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

  def logging_out?
    devise_controller? && action_name == 'destroy'
  end

  def user_not_authorized
    redirect_to root_path,
                alert: t('not_authorized')
  end
end
