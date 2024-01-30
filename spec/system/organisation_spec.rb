# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an organisation' do
  before do
    org = create(:organisation, name: 'KidsUP')
    user = create(:user, :sales, organisation: org)
    sign_in user
  end

  it 'can create an organisation as sales staff' do
    visit organisations_path
    click_link I18n.t('organisations.index.add_organisation')
    within '#org_form' do
      fill_in 'organisation_name', with: 'Test Organisation'
      fill_in 'organisation_email', with: 'test@org.jp'
      fill_in 'organisation_phone', with: '8945902345'
      fill_in 'organisation_notes', with: 'Test notes for this org'
    end
    click_button '登録する'
    expect(page).to have_content('Test Organisation')
    expect(page).to have_content('test@org.jp')
    expect(page).to have_content('8945902345')
    expect(page).to have_content('Test notes for this org')
  end
end
