# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder CustomFormBuilder
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_params, if: :devise_controller?

  before_action :set_locale

  private

  def configure_permitted_params
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name organisation_id])
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def set_locale
    locale = params[:locale] || locale_from_accept_language || I18n.default_locale
    I18n.locale = locale
  end

  def locale_from_accept_language
    http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def user_not_authorized
    redirect_to root_path,
                alert: t('not_authorized')
  end
end
