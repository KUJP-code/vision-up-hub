# frozen_string_literal: true

class TestResult < ApplicationRecord
  include Levels

  store_accessor :answers, :listening
  store_accessor :answers, :reading
  store_accessor :answers, :speaking
  store_accessor :answers, :writing

  enum :new_level, LEVELS, prefix: true
  enum :prev_level, LEVELS, prefix: true

  after_save :update_student_level

  belongs_to :test
  belongs_to :student
  delegate :organisation_id, to: :student

  validates :new_level, :prev_level, :total_percent, presence: true

  validates :listen_percent, :read_percent,
            :speak_percent, :total_percent,
            :write_percent, numericality:
            { allow_nil: true, only_integer: true,
              greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  private

  def update_student_level
    student.update!(level: new_level)
  end
end
