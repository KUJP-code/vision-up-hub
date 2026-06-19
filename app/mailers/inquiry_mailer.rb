# frozen_string_literal: true

class InquiryMailer < ApplicationMailer
  default from: 'inquiry@vision-up.app'
  layout 'mailer'

  def inquiry(inquiry)
    @inquiry = inquiry
    @received_at = Time.zone.now
    mail(
      to: ['t-nakagawa@kids-up.jp', 'p-jayson@kids-up.jp', 'r-callan@p-up.jp'],
      reply_to: inquiry.email,
      subject: 'New VisionUP Inquiry'
    )
  end

  def confirmation(inquiry)
    @inquiry = inquiry
    @received_at = Time.zone.now
    mail(to: inquiry.email, subject: '【VisionUP】お問い合わせありがとうございます')
  end
end
