# frozen_string_literal: true

FactoryBot.define do
  factory :form_template_check_box do
    input_type { 'check_box' }
    name { 'test_check_box' }
    position { 1 }
  end
end
