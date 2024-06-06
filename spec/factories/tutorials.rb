# frozen_string_literal: true

FactoryBot.define do
  factory :faq_tutorial do
    question { "sample question" }
    answer { "same answer" }
    section { "FAQ Section" }
  end


  factory :video_tutorial do
    title { "sample video" }
    section { "English Class" }
    video_path { "https://www.youtube.com/watch?v=dQw4w9WgXcQ&ab_channel=RickAstley" }
  end
end
