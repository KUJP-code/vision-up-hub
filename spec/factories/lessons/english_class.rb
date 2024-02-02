# frozen_string_literal: true

FactoryBot.define do
  factory :english_class, parent: :lesson do
    title { 'Test English Class' }
    type { 'EnglishClass' }
  end
end
