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
    visit root_path
    page.current_window.resize_to(1400, 1000)
    within '#main_nav_links' do
      find('#upload-selector-toggle').click
      click_link I18n.t('shared.upload_selector.teachers')
    end

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
      fill_in 'teacher_upload[password]', with: 'TeacherPass123'
      fill_in 'teacher_upload[password_confirmation]', with: 'TeacherPass123'
      submit = find("input[type='submit']", visible: :all)
      execute_script('arguments[0].click()', submit)
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
                        password: 'TeacherPass123',
                        password_confirmation: 'TeacherPass123')
  invalid_teacher = build(:user, :teacher, email: '')
  teachers << invalid_teacher
  teachers.map { |t| Teacher::CSV_HEADERS.map { |h| t.send(h.to_sym) } }
end
