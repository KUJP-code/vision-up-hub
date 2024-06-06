# frozen_string_literal: true

FactoryBot.define do
  factory :kindy_phonic, parent: :lesson do
    blending_words { "Blending Words 1\nBlending Words 2" }
    term { '3' }
    title { 'Test Kindy Phonics' }
    type { 'KindyPhonic' }
    unit { '10' }
    vocab { "Vocabulary 1\nVocabulary 2" }
  end
end
