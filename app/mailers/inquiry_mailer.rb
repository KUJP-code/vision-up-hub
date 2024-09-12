# frozen_string_literal: true

class InquiryMailer < ApplicationMailer
  default from: 'inquiry@vision-up.app'
  layout 'mailer'

  def inquiry(inquiry)
    @inquiry = inquiry
    mail(to: 'inquiry@vision-up.biz', subject: 'New VisionUP Inquiry')
  end
end
