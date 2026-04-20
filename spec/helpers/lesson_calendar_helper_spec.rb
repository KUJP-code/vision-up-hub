# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LessonCalendarHelper do
  describe '#calendar_entries' do
    it 'expands structured specialist evening lessons into subtype entries' do
      lesson = create(
        :evening_class,
        level: :specialist,
        subtype: nil,
        project_session_1_goal: 'Build the project',
        project_session_2_goal: 'Share the project'
      )
      course_lesson = create(:course_lesson, lesson:, week: 1, day: :monday)

      entries = helper.calendar_entries([course_lesson])

      expect(entries.map(&:subtype)).to eq(%w[project_session_1 project_session_2])
      expect(entries.map(&:lesson).uniq).to eq([lesson])
    end

    it 'ignores legacy specialist subtype lessons' do
      lesson = create(:evening_class, level: :specialist, subtype: :discussion)
      course_lesson = create(:course_lesson, lesson:, week: 1, day: :monday)

      expect(helper.calendar_entries([course_lesson])).to eq([])
    end
  end

  describe '#lesson_row' do
    it 'uses a dedicated row for keep up conversation time' do
      lesson = build(:evening_class, level: :keep_up_one, subtype: :conversation_time)

      expect(helper.lesson_row(lesson, subtype: 'conversation_time')).to eq('row-start-[28]')
    end

    it 'uses a dedicated row for specialist project session 2' do
      lesson = build(:evening_class, level: :specialist, subtype: nil)

      expect(helper.lesson_row(lesson, subtype: 'project_session_2')).to eq('row-start-[34]')
    end
  end

  describe '#calendar_lesson_title' do
    it 'shows subtype labels for evening class subtype entries' do
      lesson = build(:evening_class, subtype: :topic_study)

      expect(helper.calendar_lesson_title(lesson, subtype: 'topic_study'))
        .to eq(I18n.t('lessons.subtypes.topic_study'))
    end
  end
end
