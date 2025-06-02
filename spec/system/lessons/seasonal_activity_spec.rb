# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a seasonal activity', :js do
  let!(:org) { create(:organisation, name: 'KidsUP') }
  let(:dummy_file_path) { Rails.root.join('spec/Brett_Tanner_Resume.pdf') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a Seasonal activity' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_seasonal_activity'
    within '#seasonal_activity_form' do
      fill_in 'seasonal_activity_title', with: 'Test Seasonal Activity'
      attach_file('Ele English Class', dummy_file_path)
      attach_file('Kindy English Class', dummy_file_path)
      attach_file('Scrapbook', dummy_file_path)
      fill_in 'seasonal_activity_goal', with: 'test'
      click_button 'commit'
    end
    expect(page).to have_content('Test Seasonal Activity')
  end
end
