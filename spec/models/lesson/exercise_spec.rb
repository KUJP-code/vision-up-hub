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

  it_behaves_like 'linkable'

  it 'has a valid factory' do
    expect(build(:exercise)).to be_valid
  end

  context 'when generating PDF guide' do
    it "saves at 'exercise/level/timestamp_lesson_name_guide.pdf'" do
      exercise.save_guide
      key = exercise.guide.blob.key
      expected_path = %r{exercise/kindy/\d*_test_exercise_guide.pdf}
      expect(key).to match(expected_path)
    end

    it 'contains title and links' do
      pdf = exercise.save_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to contain_exactly(
          'Test Exercise', 'Links:', 'Example link', 'Seasonal'
        )
    end
  end
end
