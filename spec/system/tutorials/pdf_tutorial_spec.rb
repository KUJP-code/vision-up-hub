# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a PDF tutorial' do
  let(:admin_user) { create(:user, :admin) }
  let(:dummy_file_path) { Rails.root.join('spec/Brett_Tanner_Resume.pdf') }

  before do
    sign_in admin_user
    create(:tutorial_category, title: 'Extra Resources')
  end

  it 'allows an admin user to create a new PDF tutorial' do
    visit new_tutorial_path(type: 'PDF')
    fill_in 'Title', with: 'sample PDF tutorial'
    attach_file('File', dummy_file_path)
    select 'Extra Resources', from: 'Category'
    click_button 'Create PDF Tutorial'

    find('summary', text: 'Extra Resources').click
    expect(page).to have_content('sample PDF tutorial')
  end
end
