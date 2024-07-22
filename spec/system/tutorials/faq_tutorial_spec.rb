# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a FAQ tutorial' do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
    create(:tutorial_category, name: 'FAQs')
  end

  it 'allows an admin user to create a new FAQ tutorial' do
    visit new_tutorial_path(type: 'FAQ')
    fill_in 'Question', with: 'sample question'
    fill_in 'Answer', with: 'sample answer'
    select 'FAQs', from: 'Category'
    click_button 'Create FAQ Tutorial'

    find('summary', text: 'FAQs').click
    expect(page).to have_content('sample question')
  end
end
