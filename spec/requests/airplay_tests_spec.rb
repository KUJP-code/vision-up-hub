# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AirPlay video test', type: :request do
  let(:organisation) { create(:organisation, name: 'KidsUP') }

  it 'is available to admins' do
    sign_in create(:user, :admin, organisation:)

    get airplay_test_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('bipbop_16x9_variant.m3u8')
    expect(response.body).to include('Native AirPlay handoff test')
    expect(response.body).to include('Stop video & return to mirroring')
  end

  it 'is not available to non-admin users' do
    sign_in create(:user, :teacher, organisation:)

    get airplay_test_path

    expect(response).to have_http_status(:not_found)
  end
end
