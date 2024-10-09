# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'system@vision-up.app'
  layout 'mailer'
end
