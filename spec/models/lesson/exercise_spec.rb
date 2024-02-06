# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exercise do
  subject(:exercise) do
    create(
      :exercise,
      title: 'Test Exercise',
      level: :kindy,
      steps: "Step 1\nStep 2",
      links: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
    )
  end

  it 'has a valid factory' do
    expect(build(:exercise)).to be_valid
  end

  context 'when generating PDF guide' do
    it 'contains title and links' do
      pdf = exercise.attach_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to contain_exactly(
          'Test Exercise', 'Links:', 'Example link', 'Seasonal'
        )
    end
  end
end
