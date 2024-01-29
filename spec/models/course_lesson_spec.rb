# frozen_string_literal: true

RSpec.describe CourseLesson do
  it 'has a valid factory' do
    expect(build(:course_lesson)).to be_valid
  end
end
