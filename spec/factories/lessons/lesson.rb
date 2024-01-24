# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    initialize_with { type.constantize.new }
    course
    title { 'Test Lesson' }
    summary { 'Summary for test lesson' }
    week { 1 }
    day { :wednesday }
    level { :kindy }
  end
end
