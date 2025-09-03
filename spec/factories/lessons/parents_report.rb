# frozen_string_literal: true

FactoryBot.define do
  factory :parents_report, parent: :lesson do
    title { 'Test Special Lesson' }
    type { 'ParentsReport' }
  end
end
