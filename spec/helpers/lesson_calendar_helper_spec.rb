# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LessonCalendarHelper do
  describe '#calendar_entries' do
    it 'expands structured specialist evening lessons into subtype entries' do
      lesson = create(
        :evening_class,
        level: :specialist,
        subtype: nil,
        literacy_goal: 'Read together',
        discussion_goal: 'Talk together'
      )
      course_lesson = create(:course_lesson, lesson:, week: 1, day: :monday)

      entries = helper.calendar_entries([course_lesson])

      expect(entries.map(&:subtype)).to eq(%w[literacy discussion])
      expect(entries.map(&:lesson).uniq).to eq([lesson])
    end
  end

  describe '#lesson_row' do
    it 'uses a dedicated row for keep up conversation time' do
      lesson = build(:evening_class, level: :keep_up_one, subtype: :conversation_time)

      expect(helper.lesson_row(lesson, subtype: 'conversation_time')).to eq('row-start-[28]')
    end

    it 'uses a dedicated row for specialist discussion' do
      lesson = build(:evening_class, level: :specialist, subtype: nil)

      expect(helper.lesson_row(lesson, subtype: 'discussion')).to eq('row-start-[32]')
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
