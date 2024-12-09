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

    click_link 'new invoice'

    select 'Test Organisation', from: 'invoice_organisation_id'
    select 'Default', from: 'invoice_payment_option'
    fill_in 'invoice_issued_at', with: Date.today

    click_button 'Create Invoice'

    expect(page).to have_content('Invoice was successfully created')
    expect(page).to have_content('Test Organisation')
    expect(page).to have_content('50') # Number of students
    expect(page).to have_content('Default')
    expect(page).to have_content((50 * PricingCalculatable::PAYMENT_OPTIONS[:default]).to_s)
  end

  it 'shows validation errors if form is submitted without required fields' do
    visit new_invoice_path

    click_button 'Create Invoice'

    expect(page).to have_content("Organisation can't be blank")
    expect(page).to have_content("Payment option can't be blank")
    expect(page).to have_content("Issued at can't be blank")
  end
end
