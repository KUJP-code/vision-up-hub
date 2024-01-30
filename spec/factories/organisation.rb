# frozen_string_literal: true

FactoryBot.define do
  factory :organisation do
    email { 'test@org.jp' }
    name { 'Test Organisation' }
    phone { '123456789' }
  end
end
