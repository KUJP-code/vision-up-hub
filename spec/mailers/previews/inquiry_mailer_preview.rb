# frozen_string_literal: true

require 'factory_bot_rails'

class InquiryMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods

  def inquiry
    InquiryMailer.inquiry(build(:inquiry))
  end

  def confirmation
    InquiryMailer.confirmation(build(:inquiry))
  end
end
