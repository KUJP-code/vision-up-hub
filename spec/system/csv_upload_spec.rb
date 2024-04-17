# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe 'creating records from a CSV', :js do
  let(:user) { create(:user, :org_admin) }

  before do
    sign_in user
    create_invalid_student_csv
    create_valid_students_csv
  end

  after do
    File.delete('tmp/invalid.csv')
    File.delete('tmp/valid.csv')
  end

  it 'can create children from a CSV' do
    visit new_organisation_student_upload_path(organisation_id: user.organisation_id)
    within '#student_create_form' do
      # check an error is shown if students in the CSV are invalid
      attach_file 'student_upload_file', Rails.root.join('tmp/invalid.csv')
      click_button I18n.t('student_uploads.new.create_students', org: user.organisation.name)
      expect(page).to have_content(I18n.t('student_uploads.new.invalid'))

      # check success if students in the CSV are valid
      attach_file 'student_upload_file', Rails.root.join('tmp/valid.csv')
      click_button I18n.t('student_uploads.new.create_students', org: user.organisation.name)
    end
    expect(page).to have_content(I18n.t('student_uploads.new.success'))
    expect(page).to have_content(I18n.t('student_uploads.new.success_count', count: 2))
    expect(page).to have_content(I18n.t('student_uploads.new.failure_count', count: 0))
    expect(Student.count).to eq 2
  end
end

def create_invalid_student_csv
  student = build(:student, name: '', level: '')
  CSV.open('tmp/invalid.csv', 'w') do |csv|
    csv << student.attributes.keys
    csv << student.attributes.values
  end
end

def create_valid_students_csv
  students = build_list(:student, 2)
  CSV.open('tmp/valid.csv', 'w') do |csv|
    csv << Student.new.attributes.keys
    students.each do |student|
      csv << student.attributes.values
    end
  end
end
