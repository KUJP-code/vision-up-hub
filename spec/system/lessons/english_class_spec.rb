# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an EnglishClass lesson' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create an english class' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_english_class'
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

      click_button I18n.t('helpers.submit.create')
    end
    expect(page).to have_content('Test English Class')
    expect(page).to have_content('Term 1 Unit 2 - Topic')
  end
end
