# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    organisation
    name { 'Test User' }
    email { 'pC9Xp@example.com' }
    password { 'password' }
  end
end
