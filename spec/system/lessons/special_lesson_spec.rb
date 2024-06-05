# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an Special lesson' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a Special lesson' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_special_lesson'
    within '#special_lesson_form' do
      fill_in 'special_lesson_title', with: 'Test Special Lesson'
      attach_file 'special_lesson_resources',
                  Rails.root.join('spec/Brett_Tanner_Resume.pdf')

      click_button I18n.t('helpers.submit.create')
    end
    expect(page).to have_content('Test Special Lesson')
    expect(page).to have_css('a.resource', count: 1)
  end
end
