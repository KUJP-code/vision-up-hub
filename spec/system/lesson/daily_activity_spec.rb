# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a DailyActivity lesson' do
  let!(:course) { create(:course) }

  before do
    sign_in create(:user, role: :curriculum)
  end

  it 'can create a daily activity lesson' do
    visit course_path(course)
    find_by_id('add-lesson').click
    click_on 'add-daily-activity'
    within '#lesson-form' do
      fill_in 'lesson_title', with: 'Test Lesson'
      fill_in 'lesson_summary', with: 'Summary for test lesson'
      select 'Games', from: 'lesson_subcategory'
      fill_in 'lesson_week', with: 1
      select 'Wednesday', from: 'lesson_day'
      fill_in 'lesson_steps', with: 'Step 1, Step 2, Step 3'
      fill_in 'lesson_links', with: 'Example link, http://example.com, Seasonal, https://kids-up.app'
      click_on 'Create Lesson'
    end
    expect(page).to have_content('Test Lesson')
    expect(page).to have_content('Summary for test lesson')
    expect(page).to have_content('Daily Activity')
    expect(page).to have_content('Discovery')
    expect(page).to have_selector('.step', count: 3)
    expect(page).to have_selector('a.lesson-link', count: 2)
  end
end
