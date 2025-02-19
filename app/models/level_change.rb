# frozen_string_literal: true

class LevelChange < ApplicationRecord
  include Levels

  enum :new_level, LEVELS, suffix: true
  enum :prev_level, LEVELS, suffix: true
  belongs_to :student
  belongs_to :test_result, optional: true
  validates :new_level, :date_changed, presence: true

  def leveled_up?
    return false if prev_level.blank? || new_level.blank?

    new_level_before_type_cast > prev_level_before_type_cast
  end

  private
end
