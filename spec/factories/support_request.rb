# frozen_string_literal: true

FactoryBot.define do
  factory :support_request do
    body { 'I have a Request!' }
    category { :general }
    user { association :user, :org_admin }
  end
end
