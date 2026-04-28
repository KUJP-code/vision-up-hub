# frozen_string_literal: true

class InquiriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  before_action :verify_recaptcha, only: :create

  def create
    InquiryForwardingJob.perform_later(inquiry_params)

    if inquiry_params[:category] == 'join'
      redirect_to 'https://www.vision-up.biz/join-confirmed', allow_other_host: true
    else
      redirect_to 'https://www.vision-up.biz/confirmed', allow_other_host: true
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(
      :email,
      :phone,
      :message,
      :name,
      :org,
      :category,
      :postal_code,
      :address_pref,
      :address_city,
      :address_line,
      :gender,
      :age
    )
  end

  def verify_recaptcha
    result = RecaptchaVerifier.verify(
      token: params[:recaptcha_token],
      remote_ip: request.remote_ip
    )

    return if result.success?

    Rails.logger.info(
      "Rejected inquiry with failed reCAPTCHA: #{result.error_codes.join(', ')}"
    )
    redirect_to request.referer.presence || recaptcha_failure_fallback_url,
                allow_other_host: true,
                status: :see_other
  end

  def recaptcha_failure_fallback_url
    if inquiry_params[:category] == 'join'
      'https://www.vision-up.biz/join-contact'
    else
      'https://www.vision-up.biz/contact'
    end
  end
end
