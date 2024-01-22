# frozen_string_literal: true

FactoryBot.define do
  factory :daily_activity do
    course
    title { 'Test Lesson' }
    summary { 'Summary for test lesson' }
    week { 1 }
    day { :monday }
    level { :kindy }
    type { 'DailyActivity' }
    subtype { :discovery }
    steps { 'Step 1, Step 2' }
    links { 'Example link, http://example.com' }
  end
end
