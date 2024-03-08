# frozen_string_literal: true

FactoryBot.define do
  factory :test do
    name { 'Test test' }
    level { :sky_one }
    questions { "Writing: 2, 3, 4, 6\nReading: 1, 2, 3, 4 \nListening: 1, 2, 3, 4 \nSpeaking: 1, 2, 3, 4" }
    thresholds { "Sky One:60\nSky Two:70\nSky Three:80" }
  end
end
