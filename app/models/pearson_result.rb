# frozen_string_literal: true

class PearsonResult < ApplicationRecord
  belongs_to :student

  # bl 'below-level', ns 'not scored', these are pearson's codes.
  CODES = %w[ok bl ns].freeze

  validates :test_name, :test_taken_at, presence: true

  with_options inclusion: { in: CODES } do
    validates :listening_code, :reading_code, :writing_code, :speaking_code
  end

  with_options allow_nil: true, numericality: { only_integer: true } do
    validates :listening_score, :reading_score, :writing_score, :speaking_score
  end

  scope :for_test, ->(name) { where(test_name: name) }
  scope :recent,   ->       { order(test_taken_at: :desc) }
  scope :for_form, ->(f)    { where(form: f) if f.present? }

  scope :latest_per_test, lambda {
    select('DISTINCT ON (pearson_results.student_id, pearson_results.test_name) pearson_results.*')
      .reorder('pearson_results.student_id, pearson_results.test_name, pearson_results.test_taken_at DESC, pearson_results.id DESC')
  }

  def self.for_student(student_id)
    where(student_id:)
  end

  def average_score(precision: 0)
    scores = [listening_score, reading_score, writing_score, speaking_score].compact
    return nil if scores.empty?

    (scores.sum.to_f / scores.size).round(precision)
  end
end
