# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Screen mirroring video test', type: :request do
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

  it 'is not available to non-admin users' do
    sign_in create(:user, :teacher, organisation:)

    get screen_mirroring_test_path

    expect(response).to have_http_status(:not_found)
  end
end
