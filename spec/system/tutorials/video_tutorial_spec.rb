# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating and deleting a video tutorial' do
  let(:admin_user) { create(:user, :admin) }
  let!(:category) { create(:tutorial_category, title: 'Pizza') }

  before do
    sign_in admin_user
  end

  it 'allows an admin user to create a new video tutorial' do
    visit new_tutorial_path(type: 'Video')

    within 'form' do
      fill_in 'Title', with: 'sample video'
      fill_in 'Video path',
              with: 'https://www.youtube.com/watch?v=123'
      select category.title, from: 'Category'
      find('input[type="submit"]').click
    end

    find('summary', text: category.title).click
    expect(page).to have_content('sample video')
  end
end
