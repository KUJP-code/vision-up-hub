# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating Sales staff' do
  let(:organisation) { create(:organisation, name: 'KidsUP') }

  before do
    sign_in create(:user, :admin, organisation:)
  end

  it 'admin can create sales staff' do
    visit organisation_sales_path(organisation)
    click_link 'create_sale'
    expect(page).to have_content 'form'
    within '#sales_form' do
      fill_in 'sales_name', with: 'John'
      fill_in 'sales_email', with: 'xjpjv@example.com'
      click_on 'submit_sales'
    end
    expect(page).to have_content 'John'
  end
end
