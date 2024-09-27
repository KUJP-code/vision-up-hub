# frozen_string_literal: true

class InquiriesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    InquiryForwardingJob.perform_later(inquiry_params)
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:email, :phone, :message, :name)
  end
end
