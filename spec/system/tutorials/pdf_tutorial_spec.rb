# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a PDF tutorial' do
  let(:admin_user) { create(:user, :admin) }
  let(:dummy_file_path) { Rails.root.join('spec/Brett_Tanner_Resume.pdf') }
  let!(:category) { create(:tutorial_category, title: 'Pizza') }

  before do
    sign_in admin_user
  end

  it 'allows an admin user to create a new PDF tutorial' do
    visit new_tutorial_path(type: 'PDF')

    within 'form' do
      fill_in 'Title', with: 'sample PDF tutorial'
      attach_file('File', dummy_file_path)
      select category.title, from: 'Category'
      find('input[type="submit"]').click
    end

    find('summary', text: category.title).click
    expect(page).to have_content('sample PDF tutorial')
  end
end
