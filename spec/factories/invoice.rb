# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    organisation
    number_of_kids { 50 }
    issued_at { Time.current }
    seen_at { nil }
    email_sent { false }
  end
end
