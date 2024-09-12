# frozen_string_literal: true

FactoryBot.define do
  factory :inquiry do
    email { 'XkxZs@example.com' }
    name { 'Test name' }
    message { 'Test message' }
  end
end
