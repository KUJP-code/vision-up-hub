# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an Stand Show Speak lesson' do
  let!(:course) { create(:course) }
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a stand show speak lesson' do
    visit course_path(course)
    find_by_id('add-lesson').click
    click_link 'add_stand_show_speak'
    within '#stand_show_speak_form' do
      fill_in 'stand_show_speak_title', with: 'Test Stand Show Speak'
      fill_in 'stand_show_speak_goal', with: 'Test Goal'
      select 'Kindy', from: 'stand_show_speak_level'

      click_button 'Create Stand show speak'
    end
    expect(page).to have_content('Test Stand Show Speak')
    expect(page).to have_content('Test Goal')
    expect(page).to have_content('Guide is being generated')
  end
end
