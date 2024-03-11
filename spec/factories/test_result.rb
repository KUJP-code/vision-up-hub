# frozen_string_literal: true

FactoryBot.define do
  factory :test_result do
    student
    test
    new_level { :galaxy_one }
    prev_level { :sky_one }
    total_percent { 100 }
  end
end
