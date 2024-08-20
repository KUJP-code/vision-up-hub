# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    text { 'Test notification text' }
    read { false }
  end
end
