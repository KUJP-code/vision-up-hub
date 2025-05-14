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
    click_link 'create_party'
    within '#party_form' do
      fill_in 'party_title', with: 'Test Party'
      attach_file('Materials List', dummy_file_path)
      attach_file('Guides', dummy_file_path, dummy_file_path)
      attach_file('Promotion', dummy_file_path)
      fill_in 'Party Date', with: Time.Zone.Today
      fill_in 'Show From', with: Time.Zone.Today
      fill_in 'Show Until', with: Time.zone.Today + 7.days
      click_button 'commit'

      expect(page).to have_content('Test Party')
      expect(page).to have_content('img.guide_image')
    end
  end
end
