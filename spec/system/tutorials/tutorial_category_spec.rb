# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a tutorial category' do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
  end

  it 'allows an admin user to create a new tutorial category' do
    visit new_tutorial_category_path
    fill_in 'Title', with: 'New Category'
    find('input[type="submit"]').click

    expect(page).to have_content('Category was successfully created.')
    expect(page).to have_content('New Category')
  end
end
