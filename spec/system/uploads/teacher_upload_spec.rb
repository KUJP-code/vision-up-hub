# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe 'creating teacher records from a CSV', :js do
  let(:user) { create(:user, :org_admin) }

  before do
    sign_in user
    create_teachers_csv
  end

  after do
    File.delete('tmp/teachers.csv')
  end

  it 'can parse teachers from a CSV' do
    visit new_organisation_teacher_upload_path(organisation_id: user.organisation_id)
    within '#teacher_create_form' do
      attach_file 'teacher_upload_file', Rails.root.join('tmp/teachers.csv')
      click_button I18n.t('teacher_uploads.new.create_teachers', org: user.organisation.name)
    end
    expect(page).to have_css('.error', count: 1)
    expect(page).to have_css('.uploaded', count: 2)
    expect(Teacher.count).to eq(2)
    within '#teacher-row-2' do
      fill_in 'teacher_upload[name]', with: 'Jane Doe'
      fill_in 'teacher_upload[email]', with: 'jane@doe.com'
      fill_in 'teacher_upload[password]', with: 'testpassword'
      fill_in 'teacher_upload[password_confirmation]', with: 'testpassword'
      click_button 'Create User'
    end
    expect(page).to have_css('.uploaded', count: 3)
    expect(Teacher.count).to eq(3)
  end
end

def create_teachers_csv
  teachers = create_teachers
  CSV.open('tmp/teachers.csv', 'w') do |csv|
    csv << Teacher::CSV_HEADERS
    teachers.each do |teacher|
      csv << teacher
    end
  end
end

def create_teachers
  teachers = build_list(:user, 2, :teacher,
                        password: 'testpassword',
                        password_confirmation: 'testpassword')
  invalid_teacher = build(:user, :teacher, email: '')
  teachers << invalid_teacher
  teachers.map { |t| Teacher::CSV_HEADERS.map { |h| t.send(h.to_sym) } }
end
