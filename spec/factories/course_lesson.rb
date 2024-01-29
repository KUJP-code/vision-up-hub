# frozen_string_literal: true

FactoryBot.define do
  factory :course_lesson do
    course
    lesson factory: :daily_activity
    week { 1 }
    day { :monday }
  end
end
