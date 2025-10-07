# frozen_string_literal: true

FactoryBot.define do
  factory :event_activity, parent: :lesson do
    title { 'Test Event Lesson' }
    type { 'EventActivity' }
  end
end
