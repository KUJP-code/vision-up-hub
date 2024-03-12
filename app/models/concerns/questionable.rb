# frozen_string_literal: true

module Questionable
  extend ActiveSupport::Concern

  included do
    before_validation :set_questions

    def form_questions
      questions.map { |skill, scores| "#{skill}: #{scores.join(', ')}" }.join("\n")
    end

    private

    def set_questions
      self.questions = question_pairs.to_h do |pair|
        skill = pair.first.downcase.capitalize
        scores = pair.last.split(',').map(&:to_i)
        break if invalid_skill?(skill)
        break if invalid_scores?(scores)

        [skill.downcase, scores]
      end
    end

    def question_pairs
      lines = questions.split("\n").map { |s| s.gsub(/[[:space:]]/, '') }
      return if invalid_lines?(lines)

      lines.map { |s| s.split(':', 2) }.reject { |p| p[0].empty? || p[1].empty? }
    end

    def invalid_skill?(string)
      return false if self.class::SKILLS.include?(string.downcase)

      errors.add(:questions, ": #{string} is not a valid skill")
      true
    end

    def invalid_scores?(array)
      return false if array.all? { |n| n.positive? && n <= 15 }

      errors.add(:questions, ": #{array.find { |n| n.negative? || n > 15 }} is not a valid max score")
      true
    end
  end
end
