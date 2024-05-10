# frozen_string_literal: true

require 'rails_helper'
require 'csv'

# TODO: The feature works, but I can't get the test to make a request.
# Request.js never makes a PATCH request to the backend in test
# regardless of how long I wait. So this just tests parsing for now.
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
  end
end

def create_teachers_csv
  teachers = create_teachers
  create_csv(teachers)
end

def create_teachers
  teachers = build_list(:user, 2, :teacher)
  invalid_teacher = build(:user, :teacher, email: '')
  teachers << invalid_teacher
end

def create_csv(teachers)
  CSV.open('tmp/teachers.csv', 'w') do |csv|
    csv << Teacher.new.attributes.keys
    teachers.each do |teacher|
      csv << teacher.attributes.values
    end
  end
end
