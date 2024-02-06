# frozen_string_literal: true

FactoryBot.define do
  factory :english_class, parent: :lesson do
    example_sentences { "Example sentence 1\nExample sentence 2" }
    lesson_topic { 'Topic' }
    notes { "1. Note 1\n2. Note 2" }
    term { '3' }
    title { 'Test English Class' }
    type { 'EnglishClass' }
    unit { '10' }
    vocab { "Vocabulary 1\nVocabulary 2" }
  end
end
