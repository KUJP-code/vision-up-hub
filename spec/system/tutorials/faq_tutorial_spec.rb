# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a FAQ tutorial', type: :system do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
  end

  it 'allows an admin user to create a new FAQ tutorial' do
    visit new_tutorial_path(type: 'FAQ')
    fill_in 'Question', with: 'sample question'
    fill_in 'Answer', with: 'sample answer'
    click_button 'Create FAQ Tutorial'

    find('summary', text: 'FAQs').click
    expect(page).to have_content('sample question')
  end
end
