# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'changing a lesson' do
  let!(:lesson) { create(:daily_activity, creator: user, assigned_editor: user) }
  let!(:kids_up) { create(:organisation, name: 'KidsUP') }

  before do
    sign_in user
  end

  context 'when admin' do
    let(:user) { kids_up.users.create(attributes_for(:user, :admin)) }

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
    let(:user) { kids_up.users.create(attributes_for(:user, :writer)) }

    it 'proposes changes rather than editing when writer' do
      visit edit_lesson_path(id: lesson.id)
      within '#daily_activity_form' do
        fill_in 'daily_activity_title', with: 'New Title'
        fill_in 'daily_activity_instructions', with: "New Instructions 1\nNew Instructions 2"
        click_button I18n.t('helpers.submit.update')
      end
      proposed_change_list = page.find_by_id('proposals')
      expect(proposed_change_list).to have_content("Proposed by: #{user.name}")
    end
  end

  context 'when comparing lessons and accepting a proposal' do
    let(:user) { kids_up.users.create(attributes_for(:user, :admin)) }
    let(:proposal) { create(:daily_activity, :proposal, changed_lesson: lesson, title: 'New Title') }

    it 'can compare changes then accept them' do
      visit proposal_path(id: proposal.id)
      expect(page).to have_content(lesson.title)
      expect(page).to have_content('New Title')
      expect(page).to have_css('image.guide_image', count: 2)
      within '#proposal_form' do
        select 'Accept', from: 'proposal_status'
        click_button I18n.t('helpers.submit.update')
      end
      expect(page).to have_content('New Title')
      expect(lesson.reload.title).to eq('New Title')
    end
  end
end
