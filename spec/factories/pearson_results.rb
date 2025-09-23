# frozen_string_literal: true

FactoryBot.define do
  factory :pearson_result do
    association :student

    test_name { 'pearson_test' }
    form      { 'Test Form' }
    sequence(:external_test_id) { |n| n }

    sequence(:test_taken_at) { |n| Time.zone.now.change(usec: 0) + n.seconds }

    listening_score { 50 }
    listening_code  { 'ok' }
    reading_score   { 52 }
    reading_code    { 'ok' }
    writing_score   { 48 }
    writing_code    { 'ok' }
    speaking_score  { 50 }
    speaking_code   { 'ok' }

    raw { {} }

    trait :bl_listening do
      listening_score { nil }
      listening_code  { 'bl' }
    end

    trait :ns_reading do
      reading_score { nil }
      reading_code  { 'ns' }
    end
  end
end
