# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AI Sensei event accounts' do
  let(:account) { create(:user, :ai_sensei) }

  it 'signs directly into the event view even after opening a hub link' do
    get lessons_path
    post user_session_path, params: { user: { email: account.email, password: 'Password123' } }

    expect(response).to redirect_to(ai_sensei_path)
    follow_redirect!
    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.at_css('#main-nav')).to be_nil
    expect(document.at_css('.lm-hub-link')['aria-label']).to eq('ログアウト')
    expect(document.at_css('.lm-hub-link')['data-turbo-method']).to eq('delete')
    expect(response.body).not_to include('管理画面に戻る')
  end

  it 'opens directly without hub privacy or device onboarding' do
    allow(Rails.configuration.x).to receive_messages(require_privacy_policy: true, device_lock_enforced: true)
    sign_in account

    get ai_sensei_path

    expect(response).to have_http_status(:ok)
    expect(account.devices).to be_empty
  end

  it 'redirects hub and profile pages to the event view' do
    sign_in account

    [root_path, users_path, organisations_path, lessons_path, tutorials_path,
     organisation_user_path(account.organisation, account), edit_user_registration_path].each do |path|
      get path
      expect(response).to redirect_to(ai_sensei_path)
    end
  end

  it 'rejects hub writes and changes to the account without mutating data' do
    sign_in account
    expect do
      post organisations_path, params: { organisation: attributes_for(:organisation) }
      expect(response).to have_http_status(:forbidden)
    end.not_to change(Organisation, :count)

    patch user_registration_path, params: { user: { name: 'Changed' } }
    expect(response).to have_http_status(:forbidden)
    expect(account.reload.name).not_to eq('Changed')

    delete user_registration_path
    expect(response).to have_http_status(:forbidden)
    expect(User.exists?(account.id)).to be true
  end

  it 'keeps the original mirroring reference and admin tools inaccessible' do
    sign_in account

    get ai_sensei_path(reference: '2.7.9.1')
    expect(response).to redirect_to(ai_sensei_path)
    get screen_mirroring_test_path(reference: '2.7.9.1')
    expect(response).to have_http_status(:not_found)
    get devices_path
    expect(response).to have_http_status(:not_found)
    get flipper_path
    expect(response).to have_http_status(:not_found)
  end

  it 'logs out and requires authentication to return to the demo' do
    sign_in account

    delete destroy_user_session_path
    expect(response).to be_redirect
    get ai_sensei_path
    expect(response).to redirect_to(new_user_session_url)
  end

  it 'requires authentication for the event URL' do
    get ai_sensei_path

    expect(response).to redirect_to(new_user_session_url)
  end

  it 'keeps cross-domain sign in restricted to the event view' do
    browser = ActionDispatch::Integration::Session.new(Rails.application)
    browser.post 'https://vision-up.app/en/users/sign_in',
                 params: { user: { email: account.email, password: 'Password123' } }
    browser.get 'https://hub.kids-up.app/en/lessons'
    10.times do
      break unless browser.response.redirect?

      browser.follow_redirect!
    end

    expect(browser.response).to have_http_status(:ok)
    expect(browser.request.host).to eq('hub.kids-up.app')
    expect(browser.request.path).to end_with('/ai-sensei')
    expect(browser.response.body).not_to include('管理画面に戻る')
  end

  %i[org_admin teacher parent sales school_manager writer].each do |role|
    it "does not grant event access to #{role} accounts" do
      sign_in create(:user, role)

      get ai_sensei_path

      expect(response).to have_http_status(:not_found)
    end
  end

  it 'lets admins preview the event while keeping their return link' do
    sign_in create(:user, :admin)

    get ai_sensei_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('管理画面に戻る')
    expect(response.body).not_to include('aria-label=\'ログアウト\'')
  end
end
