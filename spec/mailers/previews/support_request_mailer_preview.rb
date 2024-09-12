# frozen_string_literal: true

require 'factory_bot_rails'

class SupportRequestMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods

  def new_request
    SupportRequestMailer.new_request(create(:support_request))
  end
end
