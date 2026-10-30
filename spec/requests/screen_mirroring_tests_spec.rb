# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Screen mirroring video test' do
  let(:organisation) { create(:organisation, name: 'KidsUP') }

  it 'is available to admins' do
    sign_in create(:user, :admin, organisation:)

    get screen_mirroring_test_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('今日のレッスン')
    expect(Nokogiri::HTML(response.body).css('video').size).to eq(1)
    expect(response.body).to include('player.vimeo.com/external/1225143839.m3u8')
    expect(response.body).to include('player.vimeo.com/external/1225145089.m3u8')
    expect(response.body).to include('player.vimeo.com/external/1225144027.m3u8')
    expect(response.body).to include('w1-splash')
    expect(response.body).to include('先生用ガイド')
    expect(response.body).to include('disableRemotePlayback')
    expect(response.body).to include('speech/hello')
    expect(response.body).to include('x-webkit-airplay=\'deny\'')
    document = Nokogiri::HTML(response.body)
    expect(document.at_css('body')['class']).to eq('lesson-prototype-body')
    expect(document.at_css('#main-nav')).to be_nil
    expect(document.css('.lm-sidebar [data-view]').size).to eq(4)
    expect(document.css('.lm-lesson-tabs button').size).to eq(4)
    expect(document.at_css('.lm-progress input')['type']).to eq('range')
    expect(document.at_css('button[data-screen-mirroring-test-target="subtitleButton"]')).to be_present
    expect(document.at_css('select[data-screen-mirroring-test-target="subtitlePicker"]')).to be_nil
    expect(document.css('.lm-thumbnail-activity img').size).to eq(9)
    %w[home activities].each do |view|
      cards = document.css(".lm-pages [data-view='#{view}'] .lm-content-card")
      expect(cards.size).to eq(3)
      cards.each_with_index do |card, index|
        source = card.at_css('[data-src]')
        expect(source['data-src']).to include("#{1225144025 + index}.m3u8")
        expect(source['data-content-key']).to eq("activity-#{index + 1}")
        expect(source['data-caption-src']).to include("subtitles/activity-#{index + 1}.en")
        expect(card.at_css('.lm-content-thumbnail')['data-video']).to eq(source['data-src'])
        expect(card.at_css('[data-resource-kind="guide"]')['data-content-key']).to eq("activity-#{index + 1}")
      end
    end
    content = JSON.parse(document.at_css('.lesson-mockup')['data-screen-mirroring-test-content-value'])
    expect(content.fetch('fps')).to eq(24)
    expect(content.fetch('lessons').fetch('activity-1').fetch('chapters').count { |chapter| chapter['pause_after'] }).to eq(3)
    basic_chapters = content.fetch('lessons').fetch('basic').fetch('chapters')
    expect(basic_chapters.map { |chapter| chapter.fetch('start') }).to eq(
      %w[00:00:00:07 00:00:34:00 00:03:53:00 00:06:15:00 00:08:04:00 00:08:56:00]
    )
    expect(basic_chapters.map { |chapter| chapter.fetch('end') }).to eq(
      %w[00:00:34:00 00:03:53:00 00:06:15:00 00:08:04:00 00:08:56:00 00:09:20:03]
    )
  end

  it 'renders the original 2.7.9.1 reference without mockup styles for admins' do
    sign_in create(:user, :admin, organisation:)

    get screen_mirroring_test_path(reference: '2.7.9.1')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Mirrored video with application remote')
    expect(response.body).to include('screen-mirroring-reference')
    expect(response.body).not_to include('lesson_mockup')
    expect(response.body).not_to include('lm-remote')
    document = Nokogiri::HTML(response.body)
    expect(document.css('video').size).to eq(1)
    expect(document.at_css('video')['src']).to include('1225145089.m3u8')
    expect(document.at_css('video')['preload']).to eq('metadata')
  end

  it 'keeps the reference restricted to admins' do
    sign_in create(:user, :teacher, organisation:)

    get screen_mirroring_test_path(reference: '2.7.9.1')

    expect(response).to have_http_status(:not_found)
  end

  it 'renders the isolated 2.8.3.1 layout and player for admins' do
    sign_in create(:user, :admin, organisation:)

    get screen_mirroring_test_path(reference: '2.8.3.1')

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.at_css('#main-nav')).to be_present
    expect(document.at_css('body')['class']).not_to eq('lesson-prototype-body')
    expect(document.at_css('[data-controller="screen-mirroring-2831-reference"]')).to be_present
    stylesheets = document.css('link[rel="stylesheet"]').map { |link| link['href'] }
    expect(stylesheets.any? { |href| href.include?('ai_sensei_2831_reference') }).to be true
    expect(stylesheets.any? { |href| href.include?('lesson_mockup') }).to be false
    expect(document.css('video').size).to eq(1)
    expect(document.at_css('video')['src']).to include('1225143839.m3u8')
    expect(document.at_css('video')['x-webkit-airplay']).to eq('deny')
    expect(document.css('.lm-picker')).to be_empty
  end

  it 'keeps the 2.8.3.1 comparison restricted to admins' do
    sign_in create(:user, :teacher, organisation:)

    get screen_mirroring_test_path(reference: '2.8.3.1')

    expect(response).to have_http_status(:not_found)
  end

  it 'is not available to non-admin users' do
    sign_in create(:user, :teacher, organisation:)

    get screen_mirroring_test_path

    expect(response).to have_http_status(:not_found)
  end
end
