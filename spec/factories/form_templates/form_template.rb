# frozen_string_literal: true

FactoryBot.define do
  factory :form_template do
    organisation
    title { 'Test Form Template' }
    description { 'This is a test form template' }
    fields { [attributes_for(:form_template_text_field)] }
  end
end
