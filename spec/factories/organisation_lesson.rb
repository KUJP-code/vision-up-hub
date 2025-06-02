# frozen_string_literal: true

FactoryBot.define do
  factory :organisation_lesson do
    organisation
    lesson factory: :daily_activity
    event_date { Date.current}
  end
end
