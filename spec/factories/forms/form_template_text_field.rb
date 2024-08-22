# frozen_string_literal: true

FactoryBot.define do
  factory :form_template_text_field do
    input_type { 'text_field' }
    name { 'test_text_field' }
    position { 1 }
    input_attributes { {} }
  end
end
