# frozen_string_literal: true

FactoryBot.define do
  factory :announcement do
    message { 'Test announcement' }
    start_date { Time.zone.today }
    finish_date { Time.zone.today + 7.days }
  end
end
