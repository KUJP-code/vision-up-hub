# frozen_string_literal: true

FactoryBot.define do
  factory :phonics_resource do
    lesson factory: :phonics_class
    category_resource
    week { 1 }
  end
end
