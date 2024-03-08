# frozen_string_literal: true

class Test < ApplicationRecord
  include Levelable, Thresholdable, Questionable

  SKILLS = %w[Listening Reading Speaking Writing].freeze

  validates :name, :level, :questions, :thresholds, presence: true

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
