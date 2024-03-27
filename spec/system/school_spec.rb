# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a school' do
  let(:user) { create(:user, :org_admin) }

  before do
    sign_in user
  end

  it 'can create a school as org admin' do
    I18n.with_locale(:ja) do
      visit organisation_schools_path(organisation_id: user.organisation_id)
      click_link I18n.t('schools.index.create_school')
      within '#school_form' do
        fill_in 'school_name', with: 'Test School'
      end
      click_button '登録する'
      expect(page).to have_content('Test School')
      expect(page).to have_content(I18n.t('schools.show.student_count', count: 0))
    end
  end
end
