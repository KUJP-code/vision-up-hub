# frozen_string_literal: true

FactoryBot.define do
  factory :daily_activity, parent: :lesson do
    type { 'DailyActivity' }
    subtype { :discovery }
    steps { "Step 1\nStep 2" }
    links { "Example link:http://example.com\nSeasonal:http://example.com/seasonal" }
  end
end
