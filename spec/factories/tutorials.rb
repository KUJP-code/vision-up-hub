# frozen_string_literal: true

FactoryBot.define do
  factory :tutorial_category do
    title { 'Extra Resources' }
  end

  factory :pdf_tutorial do
    title { 'sample PDF tutorial' }
    tutorial_category
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/Brett_Tanner_Resume.pdf'), 'application/pdf') }
  end

  factory :faq_tutorial do
    question { 'sample question' }
    answer { 'same answer' }
    tutorial_category
  end

  factory :video_tutorial do
    title { 'sample video' }
    tutorial_category
    video_path { 'https://www.youtube.com/watch?v=o-YBDTqX_ZU' }
  end
end
