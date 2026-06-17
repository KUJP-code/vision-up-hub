# frozen_string_literal: true

FactoryBot.define do
  factory :report_card_batch do
    school
    user
    level { 'sky' }
    status { 'complete' }
  end

  factory :pearson_report_batch do
    school
    user
    level { 'sky' }
    status { 'complete' }
  end
end
