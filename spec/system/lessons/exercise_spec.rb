# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an Exercise lesson' do
  let!(:course) { create(:course) }
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create an exercise lesson' do
    visit course_path(course)
    find_by_id('add-lesson').click
    click_link 'add_exercise'
    within '#exercise_form' do
      fill_in 'exercise_title', with: 'Test Exercise'
      select 'Kindy', from: 'exercise_level'
      fill_in 'exercise_goal', with: 'Test Goal'
      fill_in 'exercise_links', with: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
      click_button 'Create Exercise'
    end
    expect(page).to have_content('Test Exercise')
    expect(page).to have_content('Exercise')
    expect(page).to have_content('Test Goal')
    expect(page).to have_css('a.lesson_link', count: 2)
    expect(page).to have_css('a.guide_link', count: 1)
    expect(page).to have_css('img.guide_image', count: 1)
  end
end
