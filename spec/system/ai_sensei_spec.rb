# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AI Sensei event experience', :js do
  it 'signs into the demo, uses the main view, and logs out from the sidebar' do
    account = create(:user, :ai_sensei)
    visit new_user_session_path(locale: :ja)
    fill_in 'user_email', with: account.email
    fill_in 'user_password', with: 'Password123'
    find('input[type="submit"]').click

    expect(page).to have_current_path(ai_sensei_path(locale: :ja))
    expect(page).to have_css('.lm-week-card')
    expect(page).not_to have_css('#main-nav')
    expect(page).not_to have_link('管理画面に戻る')
    within('.lm-sidebar') { click_button 'アクティビティ', exact: true }
    expect(page).to have_css('.lm-page-header', text: 'アクティビティのメニュー')
    find('a[aria-label="ログアウト"]').click

    expect(page).to have_link(href: new_user_session_path(locale: :ja))
    visit ai_sensei_path(locale: :ja)
    expect(page).to have_css('form[action$="/users/sign_in"]')
    expect(page).not_to have_css('.lesson-mockup')
  end

  it 'lets an admin create an event account through the user menu' do
    admin = create(:user, :admin)
    sign_in admin
    visit users_path(locale: :en)
    find('#create_user summary').click
    click_link 'ai-sensei', exact: true
    within('#ai_sensei_form') do
      fill_in 'ai_sensei_name', with: 'Event Demo'
      fill_in 'ai_sensei_email', with: 'demo@example.com'
      click_button 'submit_ai_sensei'
    end

    expect(page).to have_field('ai_sensei_name', with: 'Event Demo')
    expect(AiSensei.find_by(email: 'demo@example.com')).to be_present
    expect(page).to have_link('Delete')
  end
end
