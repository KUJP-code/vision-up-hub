# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating and viewing an announcement' do
  let(:admin) { create(:user, :org_admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:announcement) { build(:announcement, link: students_url) }

  before do
    sign_in admin
  end

  it 'allows an admin to create an announcement' do
    visit new_announcement_path
    fill_in 'announcement_message', with: announcement.message
    fill_in 'announcement_start_date', with: announcement.start_date
    fill_in 'announcement_finish_date', with: announcement.finish_date
    fill_in 'announcement_link', with: announcement.link

    click_button 'input[type=submit]'

    expect(page).to have_content(announcement.message)

    sign_out admin
    sign_in teacher

    visit root_path

    expect(page).to have_content(announcement.message)
    expect(find_by_id('announcements')).to have_link(href: announcement.link)
  end
end
