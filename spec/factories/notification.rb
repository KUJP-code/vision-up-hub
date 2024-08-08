# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    text { 'Test notification text' }
    link { 'https://example.com' }
    read { false }
  end
end
