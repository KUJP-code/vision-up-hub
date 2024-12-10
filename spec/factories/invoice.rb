# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    organisation
    payment_option { 'default' }

    after(:build) do |invoice|
      invoice.number_of_kids = invoice.organisation.students_count
      invoice.subtotal = invoice.number_of_kids * 3500
      invoice.tax = (invoice.subtotal * 0.10).to_i
      invoice.total_cost = invoice.subtotal + invoice.tax
    end
  end
end
