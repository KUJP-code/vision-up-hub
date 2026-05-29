# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Teacher tools', type: :system do
  it 'shows compact teacher tool cards with external links' do
    organisation = create(:organisation, name: 'KidsUP')
    admin = create(:user, :admin, organisation:)
    teacher = create(:user, :teacher, organisation:)
    create(:teacher_tool,
           organisation:,
           title: 'Video Warmup',
           url: 'https://www.youtube.com/watch?v=video-warmup',
           embed_url: 'https://www.youtube.com/embed/video-warmup',
           position: 1)
    create(:teacher_tool,
           :external,
           organisation:,
           title: '2 Minute Timer',
           url: 'https://example.com/2-minute-timer',
           position: 2)

    allow(Flipper).to receive(:enabled?).and_return(false)
    allow(Flipper).to receive(:enabled?).with(:kindy, teacher).and_return(true)
    allow(Flipper).to receive(:enabled?).with(:teacher_tools, teacher).and_return(true)

    sign_in admin
    visit organisation_teacher_path(organisation, teacher)

    expect(page).to have_text('Teacher Tools')
    expect(page).to have_text('Video Warmup')
    expect(page).to have_link('2 Minute Timer', href: 'https://example.com/2-minute-timer')
  end
end
