# frozen_string_literal: true

FactoryBot.define do
  factory :daily_activity do
    course
    title { 'Test Lesson' }
    summary { 'Summary for test lesson' }
    week { 1 }
    day { :monday }
    type { 'DailyActivity' }
    subtype { :discovery }
    steps { 'Step 1, Step 2, Step 3' }
    links { 'Example link, http://example.com, Seasonal, https://kids-up.app' }
  end
end
