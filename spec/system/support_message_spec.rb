# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'replying to a support request' do
  let(:user) { create(:user, :org_admin) }
  let(:support_request) { create(:support_request, user:) }

  before do
    sign_in user
  end

  it 'can create a support request' do
    visit support_request_path(support_request)
    within '#new_support_message' do
      fill_in 'support_message_message',
              with: 'Hi, I am a test message about this support request!'
    end
    click_button I18n.t('support_requests.show.send')
    expect(page).to have_content(support_request.subject)
    expect(page).to have_content('Hi, I am a test message about this support request!')
  end
end
