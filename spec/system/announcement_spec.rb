# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating and viewing an announcement', :js do
  let(:admin) { create(:user, :org_admin) }
  let(:teacher) { create(:user, :teacher, organisation: admin.organisation) }
  let(:announcement) { build(:announcement, link: 'https://vision-up.app') }

  before do
    sign_in admin
    school = create(:school, ip: '*')
    school.teachers << teacher
  end

  it 'allows an admin to create an announcement' do
    Flipper.enable :elementary
    visit new_announcement_path
    fill_in 'announcement_message', with: announcement.message
    fill_in 'announcement_start_date', with: announcement.start_date
    fill_in 'announcement_finish_date', with: announcement.finish_date
    fill_in 'announcement_link', with: announcement.link

    click_button 'commit'

    expect(page).to have_content(announcement.message)

    sign_out admin
    sign_in teacher

    visit root_path
    click_on 'elementary'

    expect(page).to have_content(announcement.message)
    expect(find_by_id('announcements')).to have_link(href: announcement.link)
  end
end
