# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exercise do
  subject(:exercise) do
    create(
      :exercise,
      title: 'Test Exercise',
      level: :kindy,
      add_difficulty: "Difficult idea 1\nDifficult idea 2",
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
        .to include('Test Exercise', 'Example link', 'Difficult Idea 1')
    end
  end
end
