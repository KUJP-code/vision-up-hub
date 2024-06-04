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

  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:exercise)).to be_valid
  end

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = exercise.attach_guide
      expect(pdf).to be_nil
    end
  end
end
