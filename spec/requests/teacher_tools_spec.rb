# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Teacher tools', type: :request do
  let(:organisation) { create(:organisation, name: 'KidsUP') }
  let(:admin) { create(:user, :admin, organisation:) }
  let(:teacher) { create(:user, :teacher, organisation:) }
  let!(:school) { create(:school, organisation:) }
  let!(:video_tool) do
    create(:teacher_tool,
           organisation:,
           title: 'Phonics Video',
           url: 'https://www.youtube.com/watch?v=phonics-video',
           embed_url: 'https://www.youtube.com/embed/phonics-video',
           position: 1)
  end
  let!(:external_tool) do
    create(:teacher_tool,
           :external,
           organisation:,
           title: 'Quick Timer',
           url: 'https://example.com/timer',
           position: 2)
  end

  before do
    teacher.schools << school
    sign_in admin
    allow(Flipper).to receive(:enabled?).and_return(false)
    allow(Flipper).to receive(:enabled?).with(:kindy, teacher).and_return(true)
    allow(Flipper).to receive(:enabled?).with(:teacher_tools, teacher).and_return(true)
  end

  it 'shows teacher tools on the teacher page when enabled for the viewed teacher org' do
    get organisation_teacher_path(organisation, teacher)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Teacher Tools')
    expect(response.body).to include('Phonics Video')
    expect(response.body).to include('Quick Timer')
  end

  it 'hides teacher tools when the feature flag is off' do
    allow(Flipper).to receive(:enabled?).with(:teacher_tools, teacher).and_return(false)

    get organisation_teacher_path(organisation, teacher)

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('Teacher Tools')
    expect(response.body).not_to include('Phonics Video')
  end

  it 'hides teacher tools from non-admins while the feature is staff-only' do
    sign_in teacher

    get organisation_teacher_path(organisation, teacher)

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('Teacher Tools')
    expect(response.body).not_to include('Phonics Video')
    expect(response.body).not_to include('Quick Timer')
  end

  it 'renders a video preview in the modal frame for video tools' do
    get teacher_tool_preview_path(video_tool, teacher_id: teacher.id)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('turbo-frame')
    expect(response.body).to include('https://www.youtube.com/embed/phonics-video')
  end

  it 'does not render video previews for non-admins while the feature is staff-only' do
    sign_in teacher

    get teacher_tool_preview_path(video_tool, teacher_id: teacher.id)

    expect(response).to have_http_status(:not_found)
  end

  it 'returns not found for external tool previews' do
    get teacher_tool_preview_path(external_tool, teacher_id: teacher.id)

    expect(response).to have_http_status(:not_found)
  end
end
