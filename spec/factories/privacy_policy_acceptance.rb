# frozen_string_literal: true

FactoryBot.define do
  factory :privacy_policy_acceptance do
    association :user
    association :privacy_policy
    accepted_at { Time.current }
  end
end
