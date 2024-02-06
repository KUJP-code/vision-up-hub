# frozen_string_literal: true

FactoryBot.define do
  factory :phonics_class, parent: :lesson do
    title { 'Test Phonics Class' }
    type { 'PhonicsClass' }
  end
end
