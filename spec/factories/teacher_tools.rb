# frozen_string_literal: true

FactoryBot.define do
  factory :teacher_tool do
    organisation
    sequence(:title) { |n| "Teacher Tool #{n}" }
    description { 'Helpful classroom resource.' }
    kind { :video }
    sequence(:url) { |n| "https://example.com/tool-#{n}" }
    sequence(:embed_url) { |n| "https://www.youtube.com/embed/tool#{n}" }
    duration_label { '5 min' }
    sequence(:position) { |n| n }
    active { true }

    trait :external do
      kind { :external }
      embed_url { nil }
    end
  end
end
