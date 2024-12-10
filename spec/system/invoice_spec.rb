require 'rails_helper'

RSpec.describe 'Creating an Invoice' do
  let!(:admin) { create(:user, :admin) }
  let!(:organisation) { create(:organisation, name: 'Test Organisation') }
  let!(:school) { create(:school, organisation:, name: 'Test School') }
  let!(:students) { create_list(:student, 50, school:, organisation:) }

  before do
    sign_in admin
  end

  it 'allows an admin to create an invoice' do
    visit invoices_path

    click_link I18n.t 'invoices.index.new_invoice'

    select 'Test Organisation', from: 'invoice_organisation_id'
    select 'default', from: 'invoice_payment_option'

    click_button 'commit'
    number_of_students = students.size
    payment_option_rate = PricingCalculatable::PAYMENT_OPTIONS[:default]
    subtotal = number_of_students * payment_option_rate
    tax_rate = 0.1
    tax = (subtotal * tax_rate).round
    expected_total = subtotal + tax

    expect(page).to have_content('Invoice was successfully created')
    expect(page).to have_content('Test Organisation')
    expect(page).to have_content('50')
    expect(page).to have_content('default')
    expect(find('[data-test-id="invoice-total"]').text).to eq(expected_total.to_s)
    expect(page).to have_content(expected_total.to_s)
  end
end
