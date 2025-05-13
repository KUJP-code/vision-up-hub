# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating Parent' do
  let(:school) { create(:school) }
  let(:user) do
    manager = create(:user, :school_manager, organisation: school.organisation)
    manager.schools << school
    manager
  end

  before do
    sign_in user
  end

  it 'School Manager can create parent' do
    visit organisation_parents_path(organisation_id: user.organisation_id)

    find_by_id('create_user').click
    click_link 'create_parent'
    within '#parent_form' do
      fill_in 'parent_name', with: 'John'
      fill_in 'parent_email', with: 'xjpjv@example.com'
      click_on 'commit'
    end
    expect(page).to have_content 'John'
    expect(page).to have_content I18n.t('parents.show.my_children')
    expect(page).to have_content I18n.t('create_success')
  end
end
