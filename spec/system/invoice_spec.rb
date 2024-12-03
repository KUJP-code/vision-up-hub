# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating an Invoice' do
  let!(:admin) { create(:user, :admin) }
  let!(:organisation) { create(:organisation, name: 'Test Organisation', number_of_kids: 50) }

  before do
    sign_in admin # Assuming Devise or similar is being used
  end

  it 'allows an admin to create an invoice' do
    visit invoices_path

    # Click the button to navigate to the new invoice form
    click_link 'Create New Invoice'

    # Fill in the form
    select 'Test Organisation', from: 'invoice_organisation_id'
    select 'Default', from: 'invoice_payment_option'
    fill_in 'invoice_issued_at', with: Date.today

    # Submit the form
    click_button 'Create Invoice'

    # Check for success messages or resulting state
    expect(page).to have_content('Invoice was successfully created')
    expect(page).to have_content('Test Organisation')
    expect(page).to have_content('50') # Number of kids
    expect(page).to have_content('Default')
    expect(page).to have_content((50 * PricingCalculatable::PAYMENT_OPTIONS[:default]).to_s) # Subtotal
  end

  it 'shows validation errors if form is submitted without required fields' do
    visit new_invoice_path

    # Submit form without filling it in
    click_button 'Create Invoice'

    # Check for error messages
    expect(page).to have_content("Organisation can't be blank")
    expect(page).to have_content("Payment option can't be blank")
    expect(page).to have_content("Issued at can't be blank")
  end
end
