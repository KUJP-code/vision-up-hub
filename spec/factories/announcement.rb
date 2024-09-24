# frozen_string_literal: true

FactoryBot.define do
  factory :announcement do
    message { 'Test announcement' }
    valid_from { Time.Zone.today }
    valid_until { Time.Zone.today + 7.days }
    link { '/students' }
  end
end
