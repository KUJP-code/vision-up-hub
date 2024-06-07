# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an Evening class' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create an evening class' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_evening_class'
    within '#evening_class_form' do
      fill_in 'evening_class_title', with: 'Test Evening Lesson'
      fill_in 'evening_class_goal', with: 'Test Goal'
      select 'Specialist Advanced', from: 'evening_class_level'
      attach_file 'evening_class_resources',
                  Rails.root.join('spec/Brett_Tanner_Resume.pdf')
      click_button I18n.t('helpers.submit.create')
    end
    expect(page).to have_content('Test Evening Lesson')
    expect(page).to have_css('a.resource', count: 1)
  end
end
