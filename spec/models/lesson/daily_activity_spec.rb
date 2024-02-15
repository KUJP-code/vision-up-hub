# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyActivity do
  subject(:daily_activity) do
    create(
      :daily_activity,
      title: 'Test Daily Activity',
      level: :kindy,
      subtype: :discovery,
      links: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
    )
  end

  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:daily_activity)).to be_valid
  end

  context 'when generating PDF guide' do
    it 'contains title, subcategory, links and instructions' do
      pdf = daily_activity.attach_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to include(
          'Test Daily Activity', 'Discovery', 'Instructions:', '1. Instruction 1',
          '2. Instruction 2', 'Links:', 'Example link', 'Seasonal'
        )
    end
  end
end
