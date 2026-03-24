# frozen_string_literal: true

class CourseLesson < ApplicationRecord
  CSV_HEADERS = %w[lesson_id week day].freeze
  DAY_SHORTCUTS = {
    'all_weekdays' => %w[monday tuesday wednesday thursday friday],
    'all_week' => %w[sunday monday tuesday wednesday thursday friday saturday]
  }.freeze

  validates :week, :day, presence: true
  validates :week, numericality: { only_integer: true }
  validates :week, comparison: { greater_than: 0, less_than: 53 }
  validate :day_is_valid

  enum day: {
    sunday: 1,
    monday: 2,
    tuesday: 3,
    wednesday: 4,
    thursday: 5,
    friday: 6,
    saturday: 7
  }

  belongs_to :course, inverse_of: :course_lessons
  belongs_to :lesson, inverse_of: :course_lessons

  def self.day_options(include_shortcuts: false)
    options = days.keys.map { |day| [day.titleize, day] }
    return options unless include_shortcuts

    options + [['All Weekdays', 'all_weekdays'], ['All Week', 'all_week']]
  end

  def self.expand_day_selection(day)
    DAY_SHORTCUTS[day.to_s] || [day.to_s]
  end

  def day=(value)
    @invalid_day = nil
    normalized_value = value.is_a?(String) ? value.strip.downcase : value
    super(normalized_value)
  rescue ArgumentError
    @invalid_day = value
    self[:day] = nil
  end

  private

  def day_is_valid
    return if @invalid_day.blank?

    errors.add(:day, 'must be a valid day of the week')
  end
end
