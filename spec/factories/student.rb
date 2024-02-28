# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    name { 'Test Student' }
    level { 'sky_three' }
    school
  end
end
