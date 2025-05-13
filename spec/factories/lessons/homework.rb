# frozen_string_literal: true

FactoryBot.define do
    factory :homework do
      course
      level { :sky_one }
      week { 1 }
      questions { Rack::Test::UploadedFile.new(Rails.root.join('spec/Brett_Tanner_Resume.pdf'), 'application/pdf') }
      answers { Rack::Test::UploadedFile.new(Rails.root.join('spec/Brett_Tanner_Resume.pdf'), 'application/pdf') }
    end
  end
  