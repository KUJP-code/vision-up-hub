# frozen_string_literal: true

FactoryBot.define do
  factory :school_teacher do
    school
    teacher { association :user, :teacher }
  end
end
