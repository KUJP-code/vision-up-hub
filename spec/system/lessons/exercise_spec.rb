# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an Exercise lesson' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create an exercise lesson' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_exercise'
    within '#exercise_form' do
      fill_in 'exercise_title', with: 'Test Exercise'
      fill_in 'exercise_goal', with: 'Test Goal'
      select 'Kindy', from: 'exercise_level'
      select 'Aerobics', from: 'exercise_subtype'
      attach_file 'exercise_guide', Rails.root.join('spec/Brett_Tanner_Resume.pdf')
      click_button I18n.t('helpers.submit.create')
    end
    expect(page).to have_content('Test Exercise')
    expect(page).to have_content('Exercise')
  end
end
