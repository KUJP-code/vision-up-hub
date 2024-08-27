# frozen_string_literal: true

FactoryBot.define do
  factory :form_template_multi_input do
    name { 'test_multi_input' }
    position { 1 }
    input_attributes { {} }
    input_type { 'select' }

    trait :select do
      input_type { 'select' }
    end

    trait :radio_button do
      input_type { 'radio_button' }
    end
  end
end
