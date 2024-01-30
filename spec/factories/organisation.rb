# frozen_string_literal: true

FactoryBot.define do
  factory :organisation do
    sequence(:email) { |n| "test_org#{n}@org.jp" }
    sequence(:name) { |n| "Test Organisation #{n}" }
    sequence(:phone) { |n| "123456789#{n}" }
  end
end
