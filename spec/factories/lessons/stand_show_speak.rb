# frozen_string_literal: true

FactoryBot.define do
  factory :stand_show_speak, parent: :lesson do
    title { 'Test Stand Show Speak' }
    type { 'StandShowSpeak' }
  end
end
