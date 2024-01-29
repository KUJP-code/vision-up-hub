# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authorize_profiling, :set_locale

  private

  def authorize_profiling
    Rack::MiniProfiler.authorize_request if current_user&.is?('Admin')
  end

  def set_locale
    locale = params[:locale] || I18n.default_locale
    locale = :en if current_user&.is?('Admin', 'Writer')
    I18n.locale = locale
  end
end
