# frozen_string_literal: true

require 'json'
require 'net/http'

class RecaptchaVerifier
  VERIFY_URI = URI('https://www.google.com/recaptcha/api/siteverify')
  EXPECTED_ACTION = 'inquiry_submit'
  MINIMUM_SCORE = 0.5

  Result = Struct.new(:success, :error_codes, :score, :action, keyword_init: true) do
    def success?
      success
    end
  end

  def self.verify(token:, remote_ip: nil)
    new(token:, remote_ip:).verify
  end

  def initialize(token:, remote_ip: nil)
    @token = token
    @remote_ip = remote_ip
  end

  def verify
    preliminary_result || verified_result
  rescue StandardError => e
    Rails.logger.warn("reCAPTCHA verification failed: #{e.class}: #{e.message}")
    failure_result('verification-failed')
  end

  private

  attr_reader :token, :remote_ip

  def verification_params
    {
      secret:,
      response: token,
      remoteip: remote_ip
    }.compact
  end

  def secret
    ENV.fetch('RECAPTCHA_SECRET_KEY', nil)
  end

  def preliminary_result
    return skipped_result if secret.blank? && !Rails.env.production?
    return failure_result('missing-input-secret') if secret.blank?

    failure_result('missing-input-response') if token.blank?
  end

  def verified_result
    result = JSON.parse(Net::HTTP.post_form(VERIFY_URI, verification_params).body)

    Result.new(
      success: successful_response?(result),
      error_codes: result.fetch('error-codes', []),
      score: result['score'],
      action: result['action']
    )
  end

  def successful_response?(result)
    result['success'] == true &&
      result['action'] == EXPECTED_ACTION &&
      result['score'].to_f >= MINIMUM_SCORE
  end

  def skipped_result
    Result.new(success: true, error_codes: ['missing-input-secret'])
  end

  def failure_result(error_code)
    Result.new(success: false, error_codes: [error_code])
  end
end
