# frozen_string_literal: true

FactoryBot.define do
  factory :seasonal_activity, parent: :lesson do
    title { 'Test SeasonalActivity Lesson' }
    type { 'SeasonalActivity' }
  end
end
