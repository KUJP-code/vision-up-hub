# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a DailyActivity lesson' do
  let!(:course) { create(:course) }
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a daily activity lesson' do
    visit course_path(course)
    find_by_id('add-lesson').click
    click_link 'add_daily_activity'
    expect(page).to have_content('form')
    within '#daily_activity_form' do
      fill_in 'daily_activity_title', with: 'Test Daily Activity'
      fill_in 'daily_activity_summary', with: 'Summary for test daily activity'
      select 'Kindy', from: 'daily_activity_level'
      select 'Games', from: 'daily_activity_subtype'
      fill_in 'daily_activity_steps', with: "Step 1\nStep 2\nStep 3"
      fill_in 'daily_activity_links', with: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
      click_button 'Create Daily activity'
    end
    expect(page).to have_content('Test Daily Activity')
    expect(page).to have_content('Summary for test daily activity')
    expect(page).to have_content('Daily Activity')
    expect(page).to have_content('Games')
    expect(page).to have_css('.step', count: 3)
    expect(page).to have_css('a.lesson_link', count: 2)
    expect(page).to have_css('a.guide_link', count: 1)
    expect(page).to have_css('img.guide_image', count: 1)
  end
end
