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
      expect(page).to have_content('New Title')
      expect(page).to have_content('New Instructions 1', count: 1)
      expect(page).not_to have_content('Proposed Changes')
    end

    it 'shows existing resources in edit and removes checked resources on submit' do
      lesson.resources.attach(
        io: Rails.root.join('spec/example_lesson.pdf').open,
        filename: 'existing_resource.pdf',
        content_type: 'application/pdf'
      )

      visit edit_lesson_path(id: lesson.id)
      expect(page).to have_css('a.resource', text: 'existing_resource.pdf')

      within '#daily_activity_form' do
        check 'Remove'
        click_button I18n.t('helpers.submit.update')
      end

      expect(lesson.reload.resources).not_to be_attached
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

    it 'can propose deleting an existing resource' do
      lesson.resources.attach(
        io: Rails.root.join('spec/example_lesson.pdf').open,
        filename: 'existing_resource.pdf',
        content_type: 'application/pdf'
      )
      blob = lesson.resources.blobs.first

      visit edit_lesson_path(id: lesson.id)
      within '#daily_activity_form' do
        check 'Remove'
        click_button I18n.t('helpers.submit.update')
      end

      proposal = lesson.proposals.order(created_at: :desc).first
      expect(proposal.resource_deletion_blob_ids(:resources)).to include(blob.id)
    end
  end

  context 'when comparing lessons and accepting a proposal' do
    let(:user) { kids_up.users.create(attributes_for(:user, :admin)) }
    let(:course) { create(:course) }
    let(:proposal) do
      create(
        :daily_activity,
        :proposal,
        changed_lesson: lesson,
        title: 'New Title', creator: user, assigned_editor: user
      )
    end

    before do
      create(:course_lesson, course:, lesson:)
    end

    it 'can compare changes then accept them' do
      visit proposal_path(id: proposal.id)
      expect(page).to have_content(lesson.title)
      expect(page).to have_content('New Title')
      within "#proposal_status_form_#{proposal.id}" do
        select 'Accepted', from: "proposal_status_#{proposal.id}"
        click_button "proposal_status_form_submit_#{proposal.id}"
      end
      expect(page).to have_content('New Title')
      expect(page).to have_content(I18n.t('shared.visibility_toggles.accepted'))
      expect(page).to have_content(course.title)
    end

    it 'shows deleted resources and removes them when accepted' do
      lesson.resources.attach(
        io: Rails.root.join('spec/example_lesson.pdf').open,
        filename: 'removed_resource.pdf',
        content_type: 'application/pdf'
      )
      blob = lesson.resources.blobs.first
      proposal.update!(resource_deletions: { resources: [blob.id] })
      proposal.resources.attach(blob)

      visit proposal_path(id: proposal.id)
      expect(page).to have_content('Deleted')
      expect(page).to have_content('removed_resource.pdf')

      within "#proposal_status_form_#{proposal.id}" do
        select 'Accepted', from: "proposal_status_#{proposal.id}"
        click_button "proposal_status_form_submit_#{proposal.id}"
      end

      expect(lesson.reload.resources).not_to be_attached
    end
  end
end
