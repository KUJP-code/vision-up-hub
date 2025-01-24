# frozen_string_literal: true

FactoryBot.define do
  factory :level_change do
    association :test_result, strategy: :build
    new_level { 'sky_two' }
    date_changed { Time.zone.today }
  end
end
