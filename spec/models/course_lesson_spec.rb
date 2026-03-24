# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseLesson do
  it 'has a valid factory' do
    expect(build(:course_lesson)).to be_valid
  end

  it 'expands all weekdays into weekdays' do
    expect(described_class.expand_day_selection('all_weekdays')).to eq(
      %w[monday tuesday wednesday thursday friday]
    )
  end
end
