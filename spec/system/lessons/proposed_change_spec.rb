# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'changing a lesson' do
  let!(:lesson) { create(:daily_activity, creator: user, assigned_editor: user) }
  let!(:org) { create(:organisation, name: 'KidsUP') }

  context 'when admin' do
    let(:user) { org.users.create(attributes_for(:user, :admin)) }

    before do
      sign_in user
    end

    it 'edits the lesson directly' do
      visit edit_lesson_path(id: lesson.id)
      within '#daily_activity_form' do
        fill_in 'daily_activity_title', with: 'New Title'
        fill_in 'daily_activity_instructions', with: "New Instructions 1\nNew Instructions 2"
        click_button I18n.t('helpers.submit.update')
      end
      expect(page).to have_content('New Title', count: 1)
      expect(page).to have_content('New Instructions 1', count: 1)
      expect(page).not_to have_content('Proposed Changes')
    end
  end

  context 'when writer' do
    let(:user) { org.users.create(attributes_for(:user, :writer)) }

    before do
      sign_in user
    end

    it 'proposes changes rather than editing when writer' do
      visit edit_lesson_path(id: lesson.id)
      within '#daily_activity_form' do
        fill_in 'daily_activity_title', with: 'New Title'
        fill_in 'daily_activity_instructions', with: "New Instructions 1\nNew Instructions 2"
        click_button I18n.t('helpers.submit.update')
      end
      proposed_change_list = page.find_by_id('proposed-changes')
      expect(proposed_change_list).to have_content("Proposed by: #{user.name}")
    end
  end
end
