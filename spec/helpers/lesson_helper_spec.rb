# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LessonHelper do
  context 'when getting filepath for level icon' do
    it "returns 'levels/{short_level}.svg' for any elementary level" do
      level = EnglishClass.levels.keys.reject { |l| l == 'all_levels' }.sample
      lesson = build(:english_class, level:)
      short_level = lesson.short_level.downcase
      expect(level_icon_path(lesson)).to eq("levels/#{short_level}.svg")
    end

    it 'adds underscores when short level has spaces' do
      lesson = build(:english_class, level: :keep_up_one)
      expect(level_icon_path(lesson)).to eq('levels/keep_up.svg')
    end
  end

  context 'when formatting links for display in form' do
    it 'returns links as a string, text and link separated by :, links separated by \n' do
      links = "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
      lesson = build(:daily_activity, links:)
      expect(stringify_links(lesson.links)).to eq(links)
    end
  end

  context 'when getting filepath for type icon' do
    it "returns 'lesson_types/{subtype}.svg' for exercise" do
      subtype = Exercise.subtypes.keys.sample
      lesson = build(:exercise, subtype:)
      expect(type_icon_path(lesson)).to eq("lesson_types/#{subtype}.svg")
    end

    it "returns 'lesson_types/{subtype}.svg' for daily activity" do
      subtype = DailyActivity.subtypes.keys.sample
      lesson = build(:daily_activity, subtype:)
      expect(type_icon_path(lesson)).to eq("lesson_types/#{subtype}.svg")
    end

    it "returns 'lesson_types/{type}.svg' for any other type" do
      excluded_types = %w[Exercise DailyActivity]
      type = Lesson::TYPES.reject { |t| excluded_types.include?(t) }.sample.underscore
      lesson = build(type.to_sym)
      expect(type_icon_path(lesson)).to eq("lesson_types/#{type}.svg")
    end
  end
end
