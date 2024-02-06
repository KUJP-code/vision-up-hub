# frozen_string_literal: true

FactoryBot.define do
  factory :english_class, parent: :lesson do
    example_sentences { "Example sentence 1\nExample sentence 2" }
    lesson_topic { 'Topic' }
    materials { "1. Material 1\n2. Material 2" }
    notes { "1. Note 1\n2. Note 2" }
    term { 1 }
    title { 'Test English Class' }
    type { 'EnglishClass' }
    unit { 1 }
    vocab { "Vocabulary 1\nVocabulary 2" }
  end
end
