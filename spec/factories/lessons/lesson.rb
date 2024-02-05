# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    initialize_with { type.constantize.new }
    goal { 'Test Goal' }
    level { :kindy }
    title { 'Test Lesson' }
  end
end
