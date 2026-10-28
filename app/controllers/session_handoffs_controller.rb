# frozen_string_literal: true

class SessionHandoffsController < ApplicationController
  skip_before_action :ensure_privacy_policy_accepted, :ensure_device_record, :enforce_device_approval
  prepend_before_action :protect_handoff_response

  def start
    return head :bad_request unless trusted_request?
    return redirect_to after_sign_in_path_for(current_user) if user_signed_in?

    session[:session_handoff] = {
      'state' => SecureRandom.urlsafe_base64(32),
      'hosts' => SessionHandoff::HOSTS - [request.host]
    }
    try_next_host
  end

  def authorize
    payload = verified_request
    return head :bad_request unless payload && payload['source_host'] == request.host

    grant_token = if user_signed_in? && current_user.active_for_authentication?
                    SessionHandoff.issue(user: current_user, host: payload['target_host'], state: payload['state'])
                  end
    redirect_to complete_session_handoff_url(host: payload['target_host'], protocol: 'https', port: 443,
                                             handoff_token: params[:handoff_token], grant_token:),
                allow_other_host: true
  end

  def complete
    payload = verified_request
    pending = session[:session_handoff]
    return head :bad_request unless matching_request?(payload, pending)

    user = current_user || SessionHandoff.redeem(token: params[:grant_token], host: request.host,
                                                 state: pending['state'])
    user ? finish_handoff(user) : try_next_host
  end

  private

  def finish_handoff(user)
    session.delete(:session_handoff)
    unless user_signed_in?
      sign_in(:user, user)
      warden.session(:user)['password_expired'] = user.need_change_password?
    end
    redirect_to after_sign_in_path_for(user)
  end

  def protect_handoff_response
    response.headers['Cache-Control'] = 'no-store'
    response.headers['Referrer-Policy'] = 'no-referrer'
  end

  def trusted_request?
    request.ssl? && SessionHandoff::HOSTS.include?(request.host)
  end

  def verified_request
    return unless trusted_request?

    payload = verifier.verified(params[:handoff_token], purpose: :session_handoff)
    return unless payload.is_a?(Hash) && payload['state'].present?
    return unless [payload['source_host'], payload['target_host']].all? { |host| SessionHandoff::HOSTS.include?(host) }
    return if payload['source_host'] == payload['target_host']

    payload
  end

  def matching_request?(payload, pending)
    payload && pending && payload['target_host'] == request.host &&
      payload['source_host'] == pending['source_host'] &&
      ActiveSupport::SecurityUtils.secure_compare(payload['state'], pending['state'])
  end

  def try_next_host
    pending = session[:session_handoff]
    source_host = pending['hosts'].shift
    unless source_host
      session.delete(:session_handoff)
      session[:session_handoff_checked] = true
      return redirect_to new_user_session_path
    end

    pending['source_host'] = source_host
    redirect_to authorize_session_handoff_url(host: source_host, protocol: 'https', port: 443,
                                              handoff_token: request_token(pending)),
                allow_other_host: true
  end

  def request_token(pending)
    payload = pending.slice('source_host', 'state').merge('target_host' => request.host)
    verifier.generate(payload, expires_in: 2.minutes, purpose: :session_handoff)
  end

  def verifier
    Rails.application.message_verifier('session-handoff')
  end
end
