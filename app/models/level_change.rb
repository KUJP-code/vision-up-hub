# frozen_string_literal: true

class LevelChange < ApplicationRecord
  include Levels

  enum :new_level, LEVELS, suffix: true
  enum :prev_level, LEVELS, suffix: true
  before_validation :prevent_evening
  belongs_to :student
  belongs_to :test_result, optional: true
  validates :new_level, :date_changed, presence: true

  private

  def prevent_evening
    self.new_level = 'galaxy_two' if EVENING_COURSES.include?(new_level)
  end
end
