# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a tutorial', type: :system do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
  end

  it 'allows an admin user to create a new tutorial' do
    visit new_tutorial_path
    fill_in 'Title', with: 'Sample Tutorial'
    fill_in 'Content', with: 'This is some sample tutorial content.'
    click_button 'Create Tutorial'
    expect(page).to have_current_path(tutorials_path)
    expect(page).to have_content('Sample Tutorial')
    expect(page).to have_content('This is some sample tutorial content.')
  end
end
