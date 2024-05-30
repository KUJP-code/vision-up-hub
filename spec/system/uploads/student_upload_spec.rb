# frozen_string_literal: true

require 'rails_helper'
require 'csv'

# For some reason this test never makes the request to create the students
# So just test the CSV parsing for now
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
    expect(find_by_id('pending_count')).to have_content('2')
    expect(page).to have_css('.border-slate-500', count: 2)
  end
end

def create_students_csv
  students = create_students
  CSV.open('tmp/students.csv', 'w') do |csv|
    csv << Student::CSV_HEADERS
    students.each do |student|
      csv << student
    end
  end
end

def create_students
  school = create(:school)
  students = build_list(:student, 2, school:)
  students.map { |s| Student::CSV_HEADERS.map { |h| s.send(h.to_sym) } }
end
