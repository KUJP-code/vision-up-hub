# frozen_string_literal: true

FactoryBot.define do
  factory :privacy_policy do
    sequence(:version) { |n| "v#{n}.0" }
    content            { "Policy content for #{version}" }
  end
end
