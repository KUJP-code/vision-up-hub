# frozen_string_literal: true

FactoryBot.define do
  factory :exercise, parent: :lesson do
    type { 'Exercise' }
    links { "Example link:http://example.com\nSeasonal:http://example.com/seasonal" }
  end
end
