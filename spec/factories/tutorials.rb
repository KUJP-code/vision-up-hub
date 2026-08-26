# frozen_string_literal: true

FactoryBot.define do
  factory :tutorial_section do
    sequence(:title) { |number| "Resource Section #{number}" }
    position { 0 }
  end

  factory :tutorial_category do
    sequence(:title) { |number| "Extra Resources #{number}" }
    position { 0 }
    items { [] }

    trait :file do
      files { [Rack::Test::UploadedFile.new(Rails.root.join('spec/example_lesson.pdf'), 'application/pdf')] }
    end

    trait :faq do
      items { [{ 'kind' => 'faq', 'title' => 'Sample question', 'body' => 'Sample answer' }] }
    end

    trait :video do
      items do
        [{ 'kind' => 'video', 'title' => 'Sample video',
           'url' => 'https://www.youtube.com/watch?v=o-YBDTqX_ZU' }]
      end
    end

    trait :mixed do
      items do
        [
          { 'kind' => 'link', 'title' => 'Planning document', 'url' => 'https://example.com/plan' },
          { 'kind' => 'video', 'title' => 'Training video',
            'url' => 'https://www.youtube.com/watch?v=o-YBDTqX_ZU' },
          { 'kind' => 'faq', 'title' => 'What is this?', 'body' => 'A grouped resource card.' }
        ]
      end
    end
  end
end
