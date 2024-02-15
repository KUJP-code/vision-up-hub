# frozen_string_literal: true

FactoryBot.define do
  factory :proposed_change do
    goal { 'Test Goal' }
    lesson factory: :stand_show_speak
    proponent { association :user, :writer }
    title { 'Test Title' }
  end
end
