# frozen_string_literal: true

FactoryBot.define do
  factory :organisation do
    name { 'Test Organisation' }
    sequence(:email) { |n| "test_org#{n}@org.jp" }
    sequence(:phone) { |n| "123456789#{n}" }
  end
end
