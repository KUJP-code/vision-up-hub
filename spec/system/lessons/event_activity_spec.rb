# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an event activity', :js do
  let!(:org) { create(:organisation, name: 'KidsUP') }
  let(:dummy_file_path) { Rails.root.join('spec/Brett_Tanner_Resume.pdf') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create an Event activity' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_event_activity'
    within '#event_activity_form' do
      fill_in 'event_activity_title', with: 'Test Event'
      fill_in 'event_activity_goal', with: 'Sample Goal'
      click_button 'commit'
    end
    expect(page).to have_content('Test Event')
  end
end
