# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User search', :js do
  let(:user) { create(:user, :org_admin) }
  let!(:result) do
    create(:user, :parent, organisation_id: user.organisation_id,
                           name: 'Test Parent', email: 'xjpjv@example.com')
  end
  let!(:extra) { create(:user, :school_manager, organisation_id: user.organisation_id) }
  let!(:diff_org) { create(:user, :school_manager) }

  before do
    sign_in user
  end

  it 'can search parents with partial matching' do
    visit organisation_users_path(organisation_id: user.organisation_id)
    expect(page).not_to have_content(diff_org.name)
    within '#user_search' do
      fill_in 'search_email', with: 'xjpjv@exam'
      fill_in 'search_name', with: 'Test Pa'
      select 'Parent', from: 'search_type'
      click_button I18n.t('user_searches.form.search')
    end
    expect(page).to have_content(result.name)
    expect(page).not_to have_content(extra.name)
  end
end
