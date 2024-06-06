# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating and deleting a FAQ tutorial', type: :system do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
  end

  it 'allows an admin user to create a new FAQ tutorial' do
    visit new_tutorial_path(type: 'FAQ')
    fill_in 'Question', with: 'sample question"'
    fill_in 'Answer', with: 'same answer'
    select 'FAQ Section', from: 'Section'
    click_button 'Create FAQ Tutorial'
    expect(page).to have_current_path(tutorials_path)
    expect(page).to have_content('sample question')
  end

  it 'allows an admin user to delete a FAQ tutorial' do
    faq_tutorial = create(:faq_tutorial)
    visit tutorials_path
    accept_confirm do
      click_link "Delete", href: tutorial_path(faq_tutorial, type: 'FAQ')
    end
    expect(page).to have_current_path(tutorials_path)
    expect(page).to have_no_content(faq_tutorial.question)
  end
end
