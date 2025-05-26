# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating OrgAdmin' do
  let!(:org_1) { create(:organisation, name: 'KidsUP') }
  let!(:org_2) { create(:organisation, name: 'OtherOrg') }

  before do
    sign_in create(:user, :sales, organisation: org_1)
  end

  it 'sales staff can select a different org' do
    visit organisation_org_admins_path(organisation_id: org_1.id)
    find_by_id('create_user').click
    click_link 'create_org_admin'

    within '#org_admin_form' do
      select 'OtherOrg', from: 'org_admin_organisation_id'
      fill_in 'org_admin_name', with: 'John'
      fill_in 'org_admin_email', with: 'xjpjv@example.com'
      click_on 'submit_org_admin'
    end

    expect(page).to have_content 'John'
    expect(OrgAdmin.last.organisation).to eq(org_2)
  end

end
