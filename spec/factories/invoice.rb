FactoryBot.define do
  factory :invoice do
    organisation
    number_of_kids { 10 }
    payment_option { 'default' }
    subtotal { 35_000 }
    tax { 3500 }
    total_cost { 38_500 }
  end
end
