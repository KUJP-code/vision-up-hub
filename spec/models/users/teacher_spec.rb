# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teacher do
  it 'has a valid factory' do
    expect(build(:user, :teacher)).to be_valid
  end

  context 'when finding lessons for a day' do
    let(:teacher) { create(:user, :teacher) }
    let(:course) { create(:course) }
    let(:thurs_lesson) { create(:daily_activity) }

    before do
      create(:course_lesson, course:, lesson: thurs_lesson, week: 1, day: :thursday)
      create(
        :daily_activity,
        course_lessons: [create(:course_lesson, course:, week: 1, day: :tuesday)]
      )
      teacher.organisation.create_plan!(
        attributes_for(:plan,
                       course_id: course.id,
                       start: Date.parse('04-03-2024'),
                       finish_date: Date.parse('30-03-2024'))
      )
    end

    it 'can find its daily lessons for a single course' do
      date = Date.parse('07-03-2024')
      expect(teacher.day_lessons(date)).to contain_exactly(thurs_lesson)
    end

    it 'finds lessons on first Monday of plan' do
      date = Date.parse('04-03-2024')
      first_day_lesson = create(:daily_activity)
      create(:course_lesson, course:, lesson: first_day_lesson, week: 1, day: :monday)
      expect(teacher.day_lessons(date)).to contain_exactly(first_day_lesson)
    end

    it 'finds lessons for the current week on Friday' do
      date = Date.parse('08-03-2024')
      friday_lesson = create(:daily_activity)
      create(:course_lesson, course:, lesson: friday_lesson, week: 1, day: :friday)
      expect(teacher.day_lessons(date)).to contain_exactly(friday_lesson)
    end

    it 'only finds lessons for the current week of their plan' do
      date = Date.parse('14-03-2024')
      expect(teacher.day_lessons(date)).to be_empty
    end

    it 'returns nothing if past end date of plan' do
      date = Date.parse('1-04-2024')
      late_lesson = create(:daily_activity)
      create(:course_lesson, course:, lesson: late_lesson, week: 5, day: :monday)
      expect(teacher.day_lessons(date)).to be_empty
    end
  end
end
