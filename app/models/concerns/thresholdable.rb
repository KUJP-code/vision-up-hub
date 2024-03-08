# frozen_string_literal: true

module Thresholdable
  extend ActiveSupport::Concern

  included do
    before_validation :set_thresholds

    private

    def set_thresholds
      self.thresholds = threshold_pairs.to_h do |pair|
        level = pair.first.downcase.titleize
        threshold = pair.last.to_i
        break if invalid_level?(level) || invalid_threshold?(threshold)

        [level, threshold]
      end
    end

    def threshold_pairs
      lines = thresholds.split("\n")
      return if invalid_lines?(lines)

      lines.map { |s| s.split(':', 2).map(&:strip) }.reject { |p| invalid_pair?(p) }
    end

    def invalid_pair?(pair)
      if pair[0].empty?
        errors.add(:thresholds, ": Missing level for threshold #{pair[1]}")
        return true
      elsif pair[1].empty?
        errors.add(:thresholds, ": Missing threshold for #{pair[0]}")
        return true
      end
      false
    end

    def invalid_level?(string)
      return false if self.class.levels.keys.map(&:titleize).include?(string.titleize)

      errors.add(:thresholds, ": #{string} is not a valid level")
      true
    end

    def invalid_threshold?(number)
      return false if number.positive? && number <= 100

      errors.add(:thresholds, ": #{number} is not a valid threshold")
      true
    end
  end
end
