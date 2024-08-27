# frozen_string_literal: true

FactoryBot.define do
  factory :form_template_single_input do
    name { 'test_single_input' }
    position { 1 }
    input_attributes { {} }
    input_type { 'text_field' }

    trait :text_field do
      input_type { 'text_field' }
    end

    trait :text_area do
      input_type { 'text_area' }
    end

    trait :check_box do
      input_type { 'check_box' }
    end
  end
end
