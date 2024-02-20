# frozen_string_literal: true

FactoryBot.define do
  factory :school_class do
    school
    name { 'Test class' }
  end
end
