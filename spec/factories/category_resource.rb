# frozen_string_literal: true

FactoryBot.define do
  factory :category_resource do
    lesson_category { :phonics_class }
    resource_category { :phonics_sets }
  end
end
