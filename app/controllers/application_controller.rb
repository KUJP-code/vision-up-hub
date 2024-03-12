# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :authorize_profiling, :set_locale

  private

  def authorize_profiling
    Rack::MiniProfiler.authorize_request if !Rails.env.test? && current_user&.is?('Admin')
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def set_locale
    locale = params[:locale] || I18n.default_locale
    I18n.locale = locale
  end

  def user_not_authorized
    redirect_to root_path,
                alert: t('not_authorized')
  end
end
