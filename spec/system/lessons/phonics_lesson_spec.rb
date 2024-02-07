# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a Phonics lesson' do
  let!(:course) { create(:course) }
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a phonics lesson' do
    visit course_path(course)
    find_by_id('add-lesson').click
    click_link 'add_phonics_lesson'
    within '#phonics_lesson_form' do
      fill_in 'phonics_lesson_title', with: 'Test Phonics Lesson'
      fill_in 'phonics_lesson_goal', with: 'Test Goal'
      select 'Kindy', from: 'phonics_lesson_level'
      fill_in 'phonics_lesson_add_difficulty', with: "Difficult idea 1\nDifficult idea 2"
      fill_in 'phonics_lesson_extra_fun', with: "Extra 1\nExtra 2"
      fill_in 'phonics_lesson_instructions', with: "Test Instructions 1\nTest Instructions 2"
      fill_in 'phonics_lesson_links', with: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
      fill_in 'phonics_lesson_materials', with: "Material 1\nMaterial 2"
      fill_in 'phonics_lesson_notes', with: "Note 1\nNote 2"
      click_button 'Create Phonics lesson'
    end
    expect(page).to have_content('Test Phonics Lesson')
    expect(page).to have_content('Test Goal')
    expect(page).to have_content('• Difficult idea 1')
    expect(page).to have_content('• Extra 1')
    expect(page).to have_content('• Note 2')
    expect(page).to have_css('a.lesson_link', count: 2)
    expect(page).to have_content('Guide is being generated')
  end
end
