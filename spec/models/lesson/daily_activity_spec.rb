# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyActivity do
  it 'has a valid factory' do
    expect(build(:daily_activity)).to be_valid
  end

  it 'saves steps as an array split on new lines' do
    steps = "Step 1\nStep 2\nStep 3"
    expect(create(:daily_activity, steps:).steps).to eq(['Step 1', 'Step 2', 'Step 3'])
  end

  it 'saves links as hash, pairs split by line and value split by colon' do
    link_input = "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
    link_hash = { 'Example link' => 'http://example.com', 'Seasonal' => 'http://example.com/seasonal' }
    saved_links = create(:daily_activity, links: link_input).links
    expect(saved_links).to eq(link_hash)
  end

  it 'correctly sets level' do
    expect(create(:daily_activity, level: :kindy).level).to eq('kindy')
  end

  context 'when generating PDF guide' do
    it "saves at 'course_root_path/week_?/day/daily_activity/level/guide.pdf'" do
      daily_activity = create(:daily_activity, week: 1, day: :monday, level: :kindy)
      key = daily_activity.guide.blob.key
      expected_path = "#{daily_activity.course.root_path}/week_1/monday/daily_activity/kindy/guide.pdf"
      expect(key).to eq(expected_path)
    end
  end
end
