# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    initialize_with { type.constantize.new }
    title { 'Test Lesson' }
    summary { 'Summary for test lesson' }
    level { :kindy }
  end
end
