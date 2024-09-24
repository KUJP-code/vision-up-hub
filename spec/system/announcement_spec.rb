# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating and viewing an announcement', type: :system do
  let(:admin) { create(:user, :org_admin) }
  let(:teacher) { create(:user, :teacher) }

  before do
    sign_in admin
  end

  it 'allows an admin to create an announcement' do
    visit new_announcement_path

    fill_in 'announcement_message', with: 'Important announcement for students!'
    fill_in 'announcement_valid_from', with: Time.Zone.today
    fill_in 'announcement_valid_until', with: Time.Zone.today + 7.days
    fill_in 'announcement_link', with: '/students'

    click_button 'Create Announcement'

    expect(page).to have_content('Announcement created successfully')

    sign_out admin
    sign_in teacher

    visit teacher_announcements_path

    expect(page).to have_content('Important announcement for students!')
    expect(page).to have_link('More info', href: '/students')
  end
end
