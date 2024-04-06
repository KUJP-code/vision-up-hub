# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    initialize_with { type.constantize.new }
    goal { 'Test Goal' }
    level { :kindy }
    title { 'Test Lesson' }
    status { :accepted }
  end

  trait :proposal do
    status { :proposed }
    changed_lesson { create(type.underscore.to_sym) }
  end
end
