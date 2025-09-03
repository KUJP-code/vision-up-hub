# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  default from: "Vision UP <support@vision-up.app>",
          reply_to: "support@vision-up.app",
          "List-Unsubscribe" => "<mailto:support@vision-up.app?subject=unsubscribe>, <https://vision-up.app/unsubscribe>",
          "List-Unsubscribe-Post" => "List-Unsubscribe=One-Click"

  layout "mailer"

end