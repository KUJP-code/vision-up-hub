# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    name { 'Test Student' }
    birthday { '20/02/2020' }
    level { 'sky_three' }
    school
    organisation
    sex { 'male' }
    status { 'active' }
  end
end
