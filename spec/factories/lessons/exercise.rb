# frozen_string_literal: true

FactoryBot.define do
  factory :exercise, parent: :lesson do
    title { 'Test Exercise' }
    subtype { 'jumping' }
    type { 'Exercise' }
  end
end
