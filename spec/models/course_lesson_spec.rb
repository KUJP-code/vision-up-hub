# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseLesson do
  describe '.day_offset' do
    it 'uses offsets within a Monday-based week' do
      expect(described_class.day_offset(:monday)).to eq(0)
      expect(described_class.day_offset(:saturday)).to eq(5)
      expect(described_class.day_offset(:sunday)).to eq(6)
    end
  end

  it 'has a valid factory' do
    expect(build(:course_lesson)).to be_valid
  end

  it 'expands all weekdays into weekdays' do
    expect(described_class.expand_day_selection('all_weekdays')).to eq(
      %w[monday tuesday wednesday thursday friday]
    )
  end
end
