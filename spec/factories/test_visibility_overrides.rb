# frozen_string_literal: true

FactoryBot.define do
  factory :test_visibility_override do
    association :user, factory: %i[user school_manager]
    test
  end
end
