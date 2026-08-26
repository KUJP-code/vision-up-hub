# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a resource card' do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
  end

  it 'allows an admin user to create the card directly' do
    visit new_tutorial_path
    fill_in 'Resource Card Title', with: 'New Resource'
    find('input[type="submit"]').click

    expect(page).to have_content('Resource was successfully created.')
    expect(page).to have_content('New Resource')
  end
end
