# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    course
    title { 'Test Lesson' }
    summary { 'Summary for test lesson' }
    category { :english_class }
    week { 1 }
    day { :monday }
  end
end
