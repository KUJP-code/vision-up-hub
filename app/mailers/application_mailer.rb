# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # Unsubscribe stuff doesn't make sense here, it is added to try to avoid spam
  default from: 'support@vision-up.app',
          'List-Unsubscribe-Post' => 'List-Unsubscribe=One-Click',
          'List-Unsubscribe' => 'https://vision-up.app'
  layout 'mailer'
end
