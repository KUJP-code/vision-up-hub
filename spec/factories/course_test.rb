# frozen_string_literal: true

FactoryBot.define do
  factory :course_test do
    course
    test
    week { 1 }
  end
end
