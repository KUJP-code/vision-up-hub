# frozen_string_literal: true

require 'rails_helper'
require 'csv'

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
    csv << %w[name student_id level school_id parent_id start_date quit_date birthday]
    students.each do |student|
      csv << student
    end
  end
end

def create_students
  school = create(:school)
  students = build_list(:student, 2)
  invalid_student = build(:student, name: '', level: '')
  students << invalid_student
  students.map do |s|
    [s.name, s.student_id, s.level, school.id, s.parent_id,
     s.start_date, s.quit_date, s.birthday]
  end
end
