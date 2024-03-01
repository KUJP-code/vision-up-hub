# frozen_string_literal: true

FactoryBot.define do
  factory :support_message do
    support_request
    message { 'This is a test support message' }
  end
end
