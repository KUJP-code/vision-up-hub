# frozen_string_literal: true

FactoryBot.define do
  factory :evening_class, parent: :lesson do
    level { 'keep_up_two' }
    title { 'Test Evening Class' }
    type { 'EveningClass' }
  end
end
