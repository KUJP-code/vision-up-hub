# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an Stand Show Speak lesson' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a stand show speak lesson' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_stand_show_speak'
    within '#stand_show_speak_form' do
      fill_in 'stand_show_speak_title', with: 'Test Stand Show Speak'
      fill_in 'stand_show_speak_goal', with: 'Test Goal'
      attach_file 'stand_show_speak_guide',
                  Rails.root.join('spec/Brett_Tanner_Resume.pdf')
      select 'Kindy', from: 'stand_show_speak_level'

      click_button I18n.t('helpers.submit.create')
    end
    expect(page).to have_content('Test Stand Show Speak')
    expect(page).to have_content('Test Goal')
    expect(page).to have_css('a', count: 1, text: 'Lesson Plan')
  end
end
