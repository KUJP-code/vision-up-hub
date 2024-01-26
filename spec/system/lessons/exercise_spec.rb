# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an Exercise lesson' do
  let!(:course) { create(:course) }

  before do
    sign_in create(:user, :curriculum)
  end

  it 'can create an exercise lesson' do
    visit course_path(course)
    find_by_id('add-lesson').click
    click_link 'add_exercise'
    within '#exercise_form' do
      fill_in 'exercise_title', with: 'Test Exercise'
      fill_in 'exercise_summary', with: 'Summary for test exercise'
      select 'Kindy', from: 'exercise_level'
      fill_in 'exercise_links', with: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
      click_button 'Create Exercise'
    end
    expect(page).to have_content('Test Exercise')
    expect(page).to have_content('Summary for test exercise')
    expect(page).to have_content('Exercise')
    expect(page).to have_css('a.lesson_link', count: 2)
    expect(page).to have_css('a.guide_link', count: 1)
    expect(page).to have_css('img.guide_image', count: 1)
  end
end
