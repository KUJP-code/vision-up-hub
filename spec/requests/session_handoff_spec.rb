# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cross-domain sign in' do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, :admin) }
  let(:lesson) { create(:stand_show_speak, creator: user, assigned_editor: user) }
  let(:destination) { "/en/lessons/#{lesson.id}?section=2" }
  let(:browser) { ActionDispatch::Integration::Session.new(Rails.application) }

  def login_on(host, account = user)
    browser.post "https://#{host}/en/users/sign_in",
                 params: { user: { email: account.email, password: 'Password123' } }
    expect(browser.response).to have_http_status(:see_other)
  end

  def follow_to_lesson_redirect(host)
    10.times do
      break if browser.response.location == "https://#{host}#{destination}"

      browser.follow_redirect!
    end
    expect(browser.response.location).to eq("https://#{host}#{destination}")
  end

  def follow_until_destination(host)
    follow_to_lesson_redirect(host)
    browser.follow_redirect!
    expect(browser.response).to have_http_status(:ok)
  end

  it 'keeps an unauthenticated Kids UP login redirect on Kids UP' do
    browser.get "https://hub.kids-up.app#{destination}"

    expect(URI(browser.response.location).host).to eq('hub.kids-up.app')
  end

  it 'opens the exact Kids UP lesson using a Vision UP session' do
    login_on('vision-up.app')
    browser.get "https://hub.kids-up.app#{destination}"

    follow_until_destination('hub.kids-up.app')
    expect(browser.request.fullpath).to eq(destination)
    expect(SessionHandoff.count).to eq(0)
  end

  it 'finds a session on the www Vision UP domain too' do
    login_on('www.vision-up.app')
    browser.get "https://hub.kids-up.app#{destination}"

    follow_until_destination('hub.kids-up.app')
    expect(browser.request.fullpath).to eq(destination)
  end

  it 'opens a Vision UP link using a Kids UP session' do
    login_on('hub.kids-up.app')
    browser.get "https://vision-up.app#{destination}"

    follow_until_destination('vision-up.app')
    expect(browser.request.fullpath).to eq(destination)
  end

  it 'opens the lesson immediately when already signed in on that domain' do
    login_on('hub.kids-up.app')
    browser.get "https://hub.kids-up.app#{destination}"

    expect(browser.response).to have_http_status(:ok)
    expect(SessionHandoff.count).to eq(0)
  end

  it 'renders invalid password errors locally without restarting the handoff' do
    browser.post 'https://hub.kids-up.app/en/users/sign_in',
                 params: { user: { email: user.email, password: 'IncorrectPassword123' } }

    expect(browser.response).to have_http_status(:unprocessable_content)
    expect(browser.response.location).to be_nil
  end

  it 'falls back to local login and retains the lesson when no domain has a session' do
    browser.get "https://hub.kids-up.app#{destination}"
    10.times do
      break unless browser.response.redirect?

      browser.follow_redirect!
    end
    expect(browser.response).to have_http_status(:ok)
    expect(browser.request.host).to eq('hub.kids-up.app')
    expect(browser.request.path).to end_with('/users/sign_in')

    login_on('hub.kids-up.app')
    follow_until_destination('hub.kids-up.app')
  end

  it 'binds the callback to the browser that requested it and consumes the grant once' do
    login_on('vision-up.app')
    browser.get 'https://hub.kids-up.app/en/session_handoff/start'
    browser.follow_redirect!
    callback = browser.response.location
    stranger = ActionDispatch::Integration::Session.new(Rails.application)
    stranger.get callback
    expect(stranger.response).to have_http_status(:bad_request)
    expect(SessionHandoff.count).to eq(1)

    browser.get callback
    expect(browser.response).to be_redirect
    expect(SessionHandoff.count).to eq(0)
    browser.get callback
    expect(browser.response).to have_http_status(:bad_request)
  end

  it 'rejects tampered requests and never redirects to an untrusted host' do
    browser.get 'https://hub.kids-up.app/en/session_handoff/start'
    source_url = URI(browser.response.location)
    source_url.query = URI.encode_www_form(handoff_token: 'tampered')
    browser.get source_url.to_s
    expect(browser.response).to have_http_status(:bad_request)

    token = Rails.application.message_verifier('session-handoff').generate(
      { 'source_host' => 'vision-up.app', 'target_host' => 'attacker.example', 'state' => 'state' },
      expires_in: 2.minutes, purpose: :session_handoff
    )
    browser.get 'https://vision-up.app/en/session_handoff/authorize', params: { handoff_token: token }
    expect(browser.response).to have_http_status(:bad_request)
    expect(browser.response.headers['Cache-Control']).to eq('no-store')
    expect(browser.response.headers['Referrer-Policy']).to eq('no-referrer')
  end

  it 'keeps school IP restrictions when transferring a teacher session' do
    teacher = create(:user, :teacher, organisation: create(:organisation, name: 'KidsUP'))
    school = create(:school, organisation: teacher.organisation, ip: '127.0.0.1')
    teacher.schools << school
    login_on('vision-up.app', teacher)
    school.update!(ip: '192.0.2.1')
    browser.get 'https://hub.kids-up.app/en/session_handoff/start'
    browser.follow_redirect!

    expect(SessionHandoff.count).to eq(0)
    expect(browser.response).to be_redirect
    expect(browser.response.location).not_to include('/session_handoff/complete')
  end

  it 'requires privacy policy acceptance on the destination before opening the lesson' do
    create(:privacy_policy)
    login_on('vision-up.app')
    allow(Rails.configuration.x).to receive(:require_privacy_policy).and_return(true)
    browser.get "https://hub.kids-up.app#{destination}"
    follow_to_lesson_redirect('hub.kids-up.app')
    browser.follow_redirect!

    expect(URI(browser.response.location).path).to eq('/en/privacy_policy_acceptances/new')
    browser.post 'https://hub.kids-up.app/en/privacy_policy_acceptances',
                 params: { privacy_policy_acceptance: { accepted: '1' } }
    expect(browser.response.location).to eq("https://hub.kids-up.app#{destination}")
  end

  it 'enforces password expiration on the destination even if it changed during the handoff' do
    travel_to Time.zone.local(2026, 10, 28, 10) do
      login_on('vision-up.app')
      browser.get "https://hub.kids-up.app#{destination}"
      3.times { browser.follow_redirect! }
      user.update!(password_changed_at: 31.days.ago)
      follow_to_lesson_redirect('hub.kids-up.app')
      browser.follow_redirect!

      expect(URI(browser.response.location).path).to end_with('/users/password_expired')
    end
  end

  context 'when device approval is enabled' do
    let(:user) { create(:user, :writer) }

    it 'requires approval for the destination domain device' do
      login_on('vision-up.app')
      source_device_count = user.devices.count
      allow(Rails.configuration.x).to receive(:device_lock_enforced).and_return(true)
      browser.get "https://hub.kids-up.app#{destination}"
      follow_to_lesson_redirect('hub.kids-up.app')
      browser.follow_redirect!

      expect(URI(browser.response.location).path).to eq('/en/pending_device')
      expect(user.devices.pending.count).to eq(source_device_count + 1)
    end
  end
end
