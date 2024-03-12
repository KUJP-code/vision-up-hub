# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    course
    organisation
    finish_date { 12.months.from_now }
    name { 'Test Plan' }
    start { Time.zone.today.beginning_of_week }
    student_limit { 10 }
    total_cost { 1000 }
  end
end
