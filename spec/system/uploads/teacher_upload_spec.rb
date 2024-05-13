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
    expect(find_by_id('pending_count')).to have_content('3')
    expect(page).to have_css('.error', count: 1)
    expect(page).to have_css('.uploaded', count: 2)
  end
end

def create_teachers_csv
  teachers = create_teachers
  CSV.open('tmp/teachers.csv', 'w') do |csv|
    csv << %w[name email password password_confirmation]
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
  teachers.map { |t| [t.name, t.email, t.password, t.password] }
end
