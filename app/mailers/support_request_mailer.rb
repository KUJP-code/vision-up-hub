# frozen_string_literal: true

class SupportRequestMailer < ApplicationMailer
  default from: 'support@vision-up.app'
  layout 'mailer'

  def new_request(request)
    @request = request
    staff_emails = User.where(type: %w[Admin Sales]).pluck(:email)
    mail(to: staff_emails, subject: 'New VisionUP Inquiry')
  end
end
