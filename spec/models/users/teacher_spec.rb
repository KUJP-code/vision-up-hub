# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Teacher do
  let(:teacher) { create(:user, :teacher) }

  it 'has a valid factory' do
    expect(build(:user, :teacher)).to be_valid
  end

  context 'when finding lessons for a day' do
    let(:course) { create(:course) }
    let(:thurs_lesson) { create(:daily_activity) }

    before do
      create(:course_lesson, course:, lesson: thurs_lesson, week: 1, day: :thursday)
      create(
        :daily_activity,
        course_lessons: [create(:course_lesson, course:, week: 1, day: :tuesday)]
      )
      teacher.organisation.plans.create!(
        attributes_for(:plan,
                       course_id: course.id,
                       start: Date.parse('04-03-2024'),
                       finish_date: 7.days.from_now)
      )
    end

    it 'can find its daily lessons for a single course' do
      date = Date.parse('07-03-2024')
      expect(teacher.day_lessons(date)).to contain_exactly(thurs_lesson)
    end

    it 'can find daily lessons for multiple courses' do
      new_course = create(:course)
      plan_2_lesson = create(
        :daily_activity,
        course_lessons: [create(:course_lesson, course: new_course, week: 1, day: :thursday)]
      )
      teacher.organisation.plans.create!(
        attributes_for(:plan,
                       course_id: new_course.id,
                       start: Date.parse('04-03-2024'),
                       finish_date: 7.days.from_now)
      )

      date = Date.parse('07-03-2024')
      expect(teacher.day_lessons(date)).to contain_exactly(thurs_lesson, plan_2_lesson)
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
      date = Date.parse(8.days.from_now.to_s)
      late_lesson = create(:daily_activity)
      create(:course_lesson, course:, lesson: late_lesson, week: 5, day: :monday)
      expect(teacher.day_lessons(date)).to be_empty
    end
  end

  context 'when finding category resources' do
    let(:course) { create(:course) }

    before do
      teacher.organisation.plans.create(
        attributes_for(:plan, course_id: course.id)
      )
    end

    it 'gets category resources for its course' do
      category_resource = create(:category_resource)
      course.category_resources << category_resource
      expect(teacher.category_resources).to contain_exactly(category_resource)
    end

    it 'cannot access category resources for other plans' do
      create(:category_resource)
      expect(teacher.category_resources).to be_empty
    end
  end

  context 'when finding tests' do
    let(:course) { create(:course) }

    before do
      teacher.organisation.plans.create(
        attributes_for(:plan, course_id: course.id, start: 7.days.ago)
      )
    end

    it 'gets tests for this week' do
      test = create(:test)
      course.course_tests.create(test:, week: 2)
      expect(teacher.available_tests).to contain_exactly(test)
    end

    it 'gets tests for past weeks' do
      test = create(:test)
      course.course_tests.create(test:, week: 1)
      expect(teacher.available_tests).to contain_exactly(test)
    end

    it 'does not get tests for future weeks' do
      test = create(:test)
      course.course_tests.create(test:, week: 3)
      expect(teacher.available_tests.empty?).to be true
    end
  end
end
