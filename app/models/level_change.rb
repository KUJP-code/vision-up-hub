# frozen_string_literal: true

class LevelChange < ApplicationRecord
  includes Levels
  EVENING_COURSES = %w[keep_up_one keep_up_two keep_up_three specialist specialist_advanced].freeze

  enum new_level, LEVELS, suffix: true
  before_validation :prevent_evening
  belongs_to :student
  belongs_to :test_result, optional: true
  validates :new_level, :date_changed, presence: true
end

def prevent_evening
  self.new_level = 'galaxy_two' if EVENING_COURSES.include?(new_level)
end
