# frozen_string_literal: true

class Test < ApplicationRecord
  include Levelable, Thresholdable, Questionable

  SKILLS = %w[Listening Reading Speaking Writing].freeze

  validates :name, :level, :questions, :thresholds, presence: true

  has_many :test_results, dependent: :restrict_with_error
  has_many :students, through: :test_results

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
