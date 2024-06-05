# frozen_string_literal: true

FactoryBot.define do
  factory :special_lesson, parent: :lesson do
    title { 'Test Special Lesson' }
    type { 'SpecialLesson' }
  end
end
