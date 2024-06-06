# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating and deleting a video tutorial', type: :system do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
  end

  it 'allows an admin user to create a new video tutorial' do
    visit new_tutorial_path(type: 'Video')
    fill_in 'Title', with: 'sample video'
    fill_in 'Video path', with: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&ab_channel=RickAstley'
    select 'English Class', from: 'Section'
    click_button 'Create Video Tutorial'
    expect(page).to have_current_path(tutorials_path)
    expect(page).to have_content('sample video')
  end

  it 'allows an admin user to delete a video tutorial' do
    video_tutorial = create(:video_tutorial)
    visit tutorials_path
    accept_confirm do
      click_link "Delete", href: tutorial_path(video_tutorial, type: 'Video')
    end
    expect(page).to have_current_path(tutorials_path)
    expect(page).to have_no_content(video_tutorial.title)
  end
end
