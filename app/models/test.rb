# frozen_string_literal: true

class Test < ApplicationRecord
  include Levelable, Questionable

  SKILLS = %w[Listening Reading Speaking Writing].freeze

  before_validation :set_thresholds

  validates :name, :level, :questions, :thresholds, presence: true

  private

  def set_thresholds; end

  def invalid_level?(string)
    levels.keys.map(&:titleize).include?(string.titleize)
  end
end
