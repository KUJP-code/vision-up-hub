# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an Exercise lesson' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create an exercise lesson' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_exercise'
    within '#exercise_form' do
      fill_in 'exercise_title', with: 'Test Exercise'
      select 'Kindy', from: 'exercise_level'
      fill_in 'exercise_goal', with: 'Test Goal'
      fill_in 'exercise_add_difficulty', with: "Difficult idea 1\nDifficult idea 2"
      fill_in 'exercise_extra_fun', with: "Extra 1\nExtra 2"
      fill_in 'exercise_instructions', with: "Instruction 1\nInstruction 2"
      fill_in 'exercise_intro', with: "Intro 1\nIntro 2"
      fill_in 'exercise_large_groups', with: "Large groups 1\nLarge groups 2"
      fill_in 'exercise_links', with: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
      fill_in 'exercise_materials', with: "Material 1\nMaterial 2"
      fill_in 'exercise_notes', with: "Note 1\nNote 2"
      fill_in 'exercise_outro', with: "Outro 1\nOutro 2"
      click_button I18n.t('helpers.submit.create')
    end
    expect(page).to have_content('Test Exercise')
    expect(page).to have_content('Exercise')
    expect(page).to have_content('Difficult idea 1')
    expect(page).to have_content('Large groups 1')
    expect(page).to have_css('a.lesson_link', count: 2)
  end
end
