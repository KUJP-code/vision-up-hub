# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authorize_profiling

  private

  def authorize_profiling
    Rack::MiniProfiler.authorize_request if current_user&.is?('Admin')
  end
end
