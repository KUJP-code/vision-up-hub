# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an Kindy Phonics lesson' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a Kindy Phonics lesson' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_kindy_phonics'
    within '#kindy_phonics_form' do
      fill_in 'kindy_phonics_title', with: 'Test Kindy Phonics Lesson'
      fill_in 'kindy_phonics_goal', with: 'Test Goal'
      fill_in 'kindy_phonics_notes', with: "Note 1\nNote 2"
      fill_in 'kindy_phonics_term', with: '1'
      fill_in 'kindy_phonics_unit', with: '2'
      fill_in 'kindy_phonics_lesson_topic', with: 'Topic'
      fill_in 'kindy_phonics_vocab', with: "Vocab 1\nVocab 2"
      fill_in 'kindy_phonics_blending_words', with: "Blend 1\nBlend 2"

      click_button I18n.t('helpers.submit.create')
    end
    expect(page).to have_content('Test Kindy Phonics Lesson')
    expect(page).to have_content('Term 1 Unit 2 - Topic')
  end
end
