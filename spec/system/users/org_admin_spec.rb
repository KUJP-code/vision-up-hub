# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating OrgAdmin' do
  let(:organisation) { create(:organisation, name: 'KidsUP') }

  before do
    sign_in create(:user, :sales, organisation:)
  end

  it 'sales staff can create Organisation Admin' do
    visit organisation_org_admins_path(organisation)
    click_link 'create_org_admin'
    expect(page).to have_content 'form'
    within '#org_admin_form' do
      fill_in 'org_admin_name', with: 'John'
      fill_in 'org_admin_email', with: 'xjpjv@example.com'
      click_on 'submit_org_admin'
    end
    expect(page).to have_content 'John'
    expect(page).to have_content 'xjpjv@example.com'
    expect(page).to have_content 'Organisation Admin'
  end
end
