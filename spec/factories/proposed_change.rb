# frozen_string_literal: true

FactoryBot.define do
  factory :proposed_change do
    lesson factory: :stand_show_speak
    proponent { association :user, :writer }
  end
end
