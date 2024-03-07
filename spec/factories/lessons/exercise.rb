# frozen_string_literal: true

FactoryBot.define do
  factory :exercise, parent: :daily_activity do
    add_difficulty { "Difficult idea 1\nDifficult idea 2" }
    outro { "Outro 1\nOutro 2" }
    title { 'Test Exercise' }
    subtype { 'jumping' }
    type { 'Exercise' }
    links { "Example link:http://example.com\nSeasonal:http://example.com/seasonal" }
  end
end
