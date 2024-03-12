# frozen_string_literal: true

FactoryBot.define do
  factory :support_request do
    category { :general }
    description { 'My request is very important because I am!' }
    subject { 'I have a Request!' }
  end
end
