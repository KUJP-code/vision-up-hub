# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a support request' do
  let(:user) { create(:user, :teacher) }

  before do
    sign_in user
  end

  it 'can create a support request' do
    visit organisation_teacher_path(user.organisation, user)
    click_link I18n.t('teachers.nav.request_support')
    within '#support_request_form' do
      select I18n.t('support_requests.categories.bug_report'),
             from: 'support_request_category'
      fill_in 'support_request_subject', with: 'Test Subject'
      fill_in 'support_request_description', with: 'Test Description'
    end
    click_button '登録する'
    expect(page).to have_content('Test Subject')
    expect(page).to have_content('Test Description')
    expect(page).to have_content(I18n.t('support_requests.status_badge.open'))
  end
end
