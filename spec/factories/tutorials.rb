# frozen_string_literal: true

FactoryBot.define do
  factory :pdf_tutorial do
    title { 'sample PDF tutorial' }
    category { 'Manual' }
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec/Brett_Tanner_Resume.pdf'), 'application/pdf') }
  end

  factory :faq_tutorial do
    question { 'sample question' }
    answer { 'same answer' }
  end

  factory :video_tutorial do
    title { 'sample video' }
    Category { 'Extra Resources' }
    video_path { 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&ab_channel=RickAstley' }
  end
end
