# frozen_string_literal: true

class TestResult < ApplicationRecord
  include Levels

  enum :new_level, LEVELS, prefix: true
  enum :prev_level, LEVELS, prefix: true

  belongs_to :test
  belongs_to :student

  validates :new_level, :prev_level, :total_percent, presence: true

  validates :listen_percent, :read_percent,
            :speak_percent, :total_percent,
            :write_percent, numericality:
            { allow_nil: true, only_integer: true,
              greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
