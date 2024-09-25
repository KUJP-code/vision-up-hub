# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating and viewing an announcement' do
  let(:admin) { create(:user, :org_admin) }
  let(:teacher) { create(:user, :teacher) }

  before do
    sign_in admin
  end

  it 'allows an admin to create an announcement' do
    visit new_announcement_path

    fill_in 'announcement_message', with: 'Test announcement'
    fill_in 'announcement_valid_from', with: Time.Zone.today
    fill_in 'announcement_valid_until', with: Time.Zone.today + 7.days
    fill_in 'announcement_link', with: students_path

    click_button 'input[type=submit]'

    expect(page).to have_content('Test announcement')

    sign_out admin
    sign_in teacher

    visit root_path

    expect(page).to have_content('Test announcement')
    expect(find_by_id('announcements')).to have_link(href: students_path)
  end
end
