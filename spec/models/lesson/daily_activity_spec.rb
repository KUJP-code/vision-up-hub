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

  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:daily_activity)).to be_valid
  end

  context 'when generating PDF guide' do
    it 'contains title, subcategory, links and steps' do
      pdf = daily_activity.attach_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to include(
          'Test Daily Activity', 'Discovery', 'Steps:', '1. Step 1', '2. Step 2',
          'Links:', 'Example link', 'Seasonal'
        )
    end
  end
end
