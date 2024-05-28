# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Upload sample downloads' do
  let(:user) { create(:user, :org_admin) }

  before do
    sign_in user
  end

  after do
    sign_out user
  end

  it 'gets valid sample CSV for parents' do
    get organisation_parent_upload_path(user.organisation, 1)
    expect(response.body).to eq("#{Parent::CSV_HEADERS.join(',')}\n")
  end

  it 'gets valid sample CSV for teachers' do
    get organisation_teacher_upload_path(user.organisation, 1)
    expect(response.body).to eq("#{Teacher::CSV_HEADERS.join(',')}\n")
  end

  it 'gets valid sample CSV for students' do
    get organisation_student_upload_path(user.organisation, 1)
    expect(response.body).to eq("#{Student::CSV_HEADERS.join(',')}\n")
  end
end
