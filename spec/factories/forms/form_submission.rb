# frozen_string_literal: true

FactoryBot.define do
  factory :form_submission do
    parent factory: :user, type: 'Parent'
    staff factory: :user, type: 'SchoolManager'
    form_template
  end
end
