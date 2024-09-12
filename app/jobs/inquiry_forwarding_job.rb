# frozen_string_literal: true

class InquiryForwardingJob < ApplicationJob
  queue_as :inquiries

  def perform(inquiry_params)
    inquiry = Inquiry.new(inquiry_params)
    raise(ActiveModel::ValidationError, inquiry) unless inquiry.valid?

    InquiryMailer.inquiry(inquiry).deliver_now
  end
end
