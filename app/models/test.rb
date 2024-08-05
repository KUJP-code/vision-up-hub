# frozen_string_literal: true

class Test < ApplicationRecord
  include Levelable, Thresholdable, Questionable

  store_accessor :questions, :listening
  store_accessor :questions, :reading
  store_accessor :questions, :speaking
  store_accessor :questions, :writing

  SKILLS = %w[listening reading speaking writing].freeze

  validates :name, :level, :questions, :thresholds, presence: true

  has_many :course_tests, dependent: :destroy
  has_many :courses, through: :course_tests
  has_many :test_results, dependent: :restrict_with_error
  has_many :students, through: :test_results

  def max_score
    questions.values.flatten.sum + basics
  end

  private

  def invalid_lines?(array)
    array.any? do |string|
      if string.include?(':')
        false
      else
        errors.add(:base, "Missing ':' near #{string}")
        true
      end
    end
  end
end
