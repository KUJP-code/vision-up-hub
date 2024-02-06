# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an EnglishClass lesson' do
  let!(:course) { create(:course) }
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a daily activity lesson' do
    visit course_path(course)
    find_by_id('add-lesson').click
    click_link 'add_english_class'
    within '#english_class_form' do
      fill_in 'english_class_title', with: 'Test English Class'
      fill_in 'english_class_goal', with: 'Test Goal'
      select 'Kindy', from: 'english_class_level'
      fill_in 'english_class_example_sentences', with: "Example 1\nExample 2"
      fill_in 'english_class_notes', with: "Note 1\nNote 2"
      fill_in 'english_class_term', with: '1'
      fill_in 'english_class_unit', with: '2'
      fill_in 'english_class_lesson_topic', with: 'Topic'
      fill_in 'english_class_vocab', with: "Vocab 1\nVocab 2"
      click_button 'Create English class'
    end
    expect(page).to have_content('Test English Class')
    expect(page).to have_content('Term 1 Unit 2 - Topic')
    expect(page).to have_content('Guide is being generated')
  end
end
