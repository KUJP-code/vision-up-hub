# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a student' do
  let(:user) { create(:user, :school_manager) }
  let(:school) { create(:school, organisation: user.organisation) }

  before do
    user.schools << school
    sign_in user
  end

  it 'can create a class as school manager' do
    visit students_path
    click_link I18n.t('students.index.create_student')
    within '#student_form' do
      fill_in 'student_name', with: 'Test Student'
      select 'Sky 3', from: 'student_level'
      fill_in 'student_student_id', with: 's77777777'
      select school.name, from: 'student_school_id'
    end
    click_button '登録する'
    expect(page).to have_content('Test Student')
    expect(page).to have_content(I18n.t('students.show.student_id', id: 's77777777'))
    expect(page).to have_content(I18n.t('students.show.school', school: school.name))
    expect(page).to have_content('Sky 3')
    expect(page).to have_content(I18n.t('students.show.add_to_class'))
  end
end
