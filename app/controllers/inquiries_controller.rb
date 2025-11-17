# frozen_string_literal: true

class InquiriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    InquiryForwardingJob.perform_later(inquiry_params)
    redirect_to 'https://www.vision-up.biz/confirmed',
                allow_other_host: true
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
end
