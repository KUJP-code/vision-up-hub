# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin navigation' do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
    visit root_path
  end

  it 'groups occasional admin tools on the home screen' do
    expect(page).to have_link('Courses')
    expect(page).to have_link('My Account')

    expect(page).to have_no_link('Device Authorization')
    expect(page).to have_no_link('CSV Exports')
    expect(page).to have_no_link('Lesson/Course Matrix')
  end

  it 'does not show courses in the sidebar' do
    within '#main_nav_links' do
      expect(page).to have_no_link('Courses')
    end
  end
end
