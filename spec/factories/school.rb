# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    organisation
    sequence(:name) { |n| "School #{n}" }
  end
end
