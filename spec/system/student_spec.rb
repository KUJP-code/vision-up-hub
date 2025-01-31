# frozen_string_literal: true

require 'rails_helper', skip: 'Student creation is temporarily postponed'

RSpec.describe 'creating a student' do
  let(:user) { create(:user, :school_manager) }
  let(:school) { create(:school, organisation: user.organisation) }

  before do
    school.classes << create(:school_class)
    user.schools << school
    sign_in user
  end

  it 'can create a student as school manager' do
    visit students_path
    click_link I18n.t('students.index.create_student')
    within '#student_form' do
      fill_in 'student_name', with: 'Test Student'
      select 'Sky Three', from: 'student_level'
      fill_in 'student_student_id', with: 's77777777'
      fill_in 'student_birthday', with: '20/02/2020'
      select user.organisation.name, from: 'student_organisation_id'
      select school.name, from: 'student_school_id'
    end
    click_button '登録する'
    expect(page).to have_content(/\*\*\*\*|Test Student/)
    expect(page).to have_content(I18n.t('students.details.student_id', id: 's77777777'))
    expect(page).to have_content('Sky Three')
    expect(page).to have_selector(:button, I18n.t('students.details.add_to_class'))
  end
end
