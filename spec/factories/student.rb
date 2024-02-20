# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    name { 'Test Student' }
    school
  end
end
