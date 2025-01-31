# frozen_string_literal: true

require 'rails_helper', skip: 'Events dont exist yet'

RSpec.describe 'creating an Event activity' do
  let!(:org) { create(:organisation, name: 'KidsUP') }
  let(:dummy_file_path) { Rails.root.join('spec/Brett_Tanner_Resume.pdf') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create an Event activity' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_Event'
    within '#Event_form' do
      fill_in 'event_title', with: 'Test Event'
      attach_file('Materials List', dummy_file_path)
      attach_file('Guides', dummy_file_path, dummy_file_path)
      attach_file('Promotion', dummy_file_path)
      fill_in 'Event Date', with: Time.Zone.Today
      fill_in 'Show From', with: Time.Zone.Today
      fill_in 'Show Until', with: Time.zone.Today + 7.days
      click_button 'commit'

      expect(page).to have_content('Test Event')
      expect(page).to have_content('img.guide_image')
    end
  end
end
