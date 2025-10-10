# frozen_string_literal: true

FactoryBot.define do
  factory :lesson_link do
    association :lesson, factory: :english_class
    title { 'Example link' }
    url   { 'https://youtu.be/abc123' }

    trait(:youtube)    { url { 'https://youtu.be/abc123' } }
    trait(:vimeo)      { url { 'https://vimeo.com/987654' } }
    trait(:google_doc) { url { 'https://docs.google.com/document/d/xyz123/edit' } }
  end
end
