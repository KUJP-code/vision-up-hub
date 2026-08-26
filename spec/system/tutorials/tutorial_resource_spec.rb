# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Managing resource cards', :js do
  let(:admin_user) { create(:user, :admin) }

  before { sign_in admin_user }

  it 'adds different item types to one resource card' do
    visit new_tutorial_path

    within 'form' do
      fill_in 'Resource Card Title', with: 'Ordering Help'
      click_button 'Add Link'
      click_button 'Add Video'
      click_button 'Add FAQ'

      within all('[data-resource-item]')[0] do
        fill_in 'Title', with: 'Order form'
        fill_in 'URL', with: 'https://example.com/order'
      end
      within all('[data-resource-item]')[1] do
        fill_in 'Title', with: 'Ordering video'
        fill_in 'Video URL', with: 'https://www.youtube.com/watch?v=123'
      end
      within all('[data-resource-item]')[2] do
        fill_in 'Question', with: 'How do I order?'
        fill_in 'Answer', with: 'Choose a size first.'
      end
      find('input[type="submit"]').click
    end

    click_button 'Ordering Help'
    expect(page).to have_content('Order form')
    expect(page).to have_content('Ordering video')
    expect(page).to have_content('How do I order?')
  end
end
