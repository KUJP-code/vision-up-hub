# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a FAQ tutorial' do
  let(:admin_user) { create(:user, :admin) }
  let!(:category) { create(:tutorial_category, title: 'Pizza') }

  before do
    sign_in admin_user
  end

  it 'allows an admin user to create a new FAQ tutorial' do
    visit new_tutorial_path(type: 'FAQ')

    within 'form' do
      fill_in 'Question', with: 'sample question'
      fill_in 'Answer', with: 'sample answer'
      select category.title, from: 'Category'
      find('input[type="submit"]').click
    end

    find('summary', text: category.title).click
    expect(page).to have_content('sample question')
  end
end
