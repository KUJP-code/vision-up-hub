# frozen_string_literal: true

require 'rails_helper'
require 'csv'

# TODO: The feature works, but I can't get the test to make a request.
# Request.js never makes a PATCH request to the backend in test
# regardless of how long I wait. So this just test parsing for now.
RSpec.describe 'creating student records from a CSV', :js do
  let(:user) { create(:user, :org_admin) }

  before do
    sign_in user
    create_students_csv
  end

  after do
    File.delete('tmp/students.csv')
  end

  it 'can parse children from a CSV' do
    visit new_organisation_student_upload_path(organisation_id: user.organisation_id)
    within '#student_create_form' do
      attach_file 'student_upload_file', Rails.root.join('tmp/students.csv')
      click_button I18n.t('student_uploads.new.create_students', org: user.organisation.name)
    end
    expect(find_by_id('pending_count')).to have_content('3')
    expect(page).to have_css('.border-red-500', count: 1)
    expect(page).to have_css('.border-slate-500', count: 2)
  end
end

def create_students_csv
  students = create_students
  CSV.open('tmp/students.csv', 'w') do |csv|
    csv << Student.new.attributes.keys
    students.each do |student|
      csv << student.attributes.values
    end
  end
end

def create_students
  school = create(:school)
  students = build_list(:student, 2, school_id: school.id)
  invalid_student = build(:student, name: '', level: '', school_id: school.id)
  students << invalid_student
end
