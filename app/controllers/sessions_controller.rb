# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  def new
    return super unless request.get? && request.ssl? && SessionHandoff::HOSTS.include?(request.host)
    return super if user_signed_in? || session.delete(:session_handoff_checked)

    redirect_to start_session_handoff_path
  end
end
