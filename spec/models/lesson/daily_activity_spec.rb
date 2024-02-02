# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyActivity do
  subject(:daily_activity) do
    create(
      :daily_activity,
      title: 'Test Daily Activity',
      level: :kindy,
      subtype: :discovery,
      steps: "Step 1\nStep 2",
      links: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
    )
  end

  it 'has a valid factory' do
    expect(build(:daily_activity)).to be_valid
  end

  it_behaves_like 'linkable'
  it_behaves_like 'steppable'

  context 'when generating PDF guide' do
    it "saves at 'daily_activity/level/subtype/timestamp_lesson_name_guide.pdf'" do
      daily_activity.save_guide
      key = daily_activity.guide.blob.key
      expected_path = %r{daily_activity/kindy/discovery/\d*_test_daily_activity_guide.pdf}
      expect(key).to match(expected_path)
    end

    it 'contains title, subcategory, links and steps' do
      pdf = daily_activity.save_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to contain_exactly(
          'Test Daily Activity', 'Summary for test daily activity', 'Discovery',
          'Steps:', '1. Step 1', '2. Step 2', 'Links:', 'Example link', 'Seasonal'
        )
    end
  end
end
