# frozen_string_literal: true

module Questionable
  extend ActiveSupport::Concern

  included do
    before_validation :set_questions

    private

    def set_questions
      self.questions = question_pairs.to_h do |pair|
        skill = pair.first.downcase.capitalize
        scores = pair.last.split(',').map(&:to_i)
        break if invalid_skill?(skill)
        break if invalid_scores?(scores)

        [skill, scores]
      end
    end

    def question_pairs
      lines = questions.split("\n").map { |s| s.gsub(/[[:space:]]/, '') }
      return if invalid_lines?(lines)

      lines.map { |s| s.split(':', 2) }.reject { |p| p[0].empty? || p[1].empty? }
    end

    def invalid_lines?(array)
      array.any? do |string|
        if string.include?(':')
          false
        else
          errors.add(:questions, ": Missing ':' near #{string}")
          true
        end
      end
    end

    def invalid_skill?(string)
      if self.class::SKILLS.include?(string)
        false
      else
        errors.add(:questions, ": #{string} is not a valid skill")
        true
      end
    end

    def invalid_scores?(array)
      array.any? do |n|
        if n.negative? || n > 15
          errors.add(:questions, ": #{n} is not a valid max score")
          true
        else
          false
        end
      end
    end
  end
end
