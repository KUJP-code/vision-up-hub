# frozen_string_literal: true

FactoryBot.define do
  factory :party_activity, parent: :lesson do
    title { 'Test PartyActivity Lesson' }
    type { 'PartyActivity' }
  end
end
