# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Upload pages' do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
  end

  it 'renders CSV upload pages with contained format tables' do
    [
      new_organisation_student_upload_path(admin.organisation),
      new_organisation_teacher_upload_path(admin.organisation),
      new_organisation_parent_upload_path(admin.organisation)
    ].each do |path|
      get path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('overflow-x-auto')
      expect(response.body).to include('min-w-max')
    end
  end
end
