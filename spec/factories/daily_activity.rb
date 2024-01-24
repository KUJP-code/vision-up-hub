# frozen_string_literal: true

FactoryBot.define do
  factory :daily_activity do
    course
    title { 'Test Daily Activity' }
    summary { 'Summary for test daily activity' }
    week { 1 }
    day { :wednesday }
    level { :kindy }
    type { 'DailyActivity' }
    subtype { :discovery }
    steps { "Step 1\nStep 2" }
    links { "Example link:http://example.com\nSeasonal:http://example.com/seasonal" }
  end
end
