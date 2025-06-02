# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a Party', :js do
  let!(:org) { create(:organisation, name: 'KidsUP') }
  let(:dummy_file_path) { Rails.root.join('spec/Brett_Tanner_Resume.pdf') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create an Party' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_party_activity'
    within '#party_activity_form' do
      fill_in 'party_activity_title', with: 'Test Party'
      fill_in 'party_activity_goal', with: 'Sample goal'
      click_button 'commit'
    end
    expect(page).to have_content('Test Party')
  end
end
