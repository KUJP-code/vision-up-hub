# frozen_string_literal: true

class InquiryMailer < ApplicationMailer
  default from: 'inquiry@vision-up.app'
  layout 'mailer'

  def inquiry(inquiry)
    @inquiry = inquiry
    mail(to: ['t-nakagawa@kids-up.jp', 'p-jayson@kids-up.jp'], subject: 'New VisionUP Inquiry')
  end
end
