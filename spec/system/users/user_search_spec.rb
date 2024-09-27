# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User search', :js do
  let(:user) { create(:user, :org_admin) }
  let!(:result) do
    create(:user, :parent, organisation_id: user.organisation_id,
                           name: 'Test Parent', email: 'xjpjv@example.com')
  end

  before do
    sign_in user
  end

  context 'when searching index' do
    let!(:extra) { create(:user, :school_manager, organisation_id: user.organisation_id) }
    let!(:diff_org_user) { create(:user, :school_manager) }

    it 'can search parents with partial matching' do
      visit organisation_users_path(organisation_id: user.organisation_id)
      expect(page).not_to have_content(diff_org_user.name)
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

  context 'when adding a parent to orphan' do
    let(:school) { create(:school, organisation_id: user.organisation_id) }
    let!(:orphan) { create(:student, parent_id: nil, school_id: school.id) }

    it 'can search and claim a parent' do
      visit student_path(id: orphan.id)
      within '#user_search' do
        fill_in 'search_email', with: 'xjpjv'
        fill_in 'search_name', with: 'ent'
        click_button I18n.t('user_searches.form.search')
      end
      click_button I18n.t('users.table.add_as_parent')
      expect(page).to have_content(I18n.t('update_success'))
      expect(orphan.reload.parent_id).to eq result.id
    end
  end
end
