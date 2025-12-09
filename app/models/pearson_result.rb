# frozen_string_literal: true

class PearsonResult < ApplicationRecord
  belongs_to :student

  # bl 'below-level', ns 'not scored', these are pearson's codes.
  CODES = %w[ok bl ns].freeze
  SKILLS = %w[listening reading writing speaking].freeze

  GSE_RANGES = {
    /benchmark\s+young\s+learners\s+level\s+1/i => (10..27),
    /benchmark\s+young\s+learners\s+level\s+2/i => (16..34),
    /benchmark\s+young\s+learners\s+level\s+3/i => (22..40),
    /benchmark\s+young\s+learners\s+level\s+4/i => (27..45),
    /benchmark\s+young\s+learners\s+level\s+5/i => (33..52),
    /benchmark\s+young\s+learners\s+level\s+6/i => (42..58),
    /benchmark\s+test\s+a/i => (30..42),
    /benchmark\s+test\s+b1/i => (43..58),
    /benchmark\s+test\s+b2/i => (59..75),
    /benchmark\s+test\s+c/i => (76..90)
  }.freeze

  DEFAULT_GSE_RANGE = (0..90)
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

  def display_score_for(skill)
    score = public_send(:"#{skill}_score")
    code  = public_send(:"#{skill}_code")

    return score if score.present?

    case code
    when 'bl' then 'BL'
    when 'ns' then 'NS'
    else '--'
    end
  end

  def radar_scores
    SKILLS.map { |skill| gse_score_for(skill) }
  end

  def contains_below_level_score?
    SKILLS.any? { |skill| public_send(:"#{skill}_code") == 'bl' }
  end

  def below_level_indices
    SKILLS.each_index.select { |idx| public_send(:"#{SKILLS[idx]}_code") == 'bl' }
  end

  def gse_range
    GSE_RANGES.each do |matcher, range|
      return range if matcher.match?(test_name.to_s)
    end

    DEFAULT_GSE_RANGE
  end

  def average_score(precision: 0)
    scores = [listening_score, reading_score, writing_score, speaking_score].compact
    return nil if scores.empty?

    (scores.sum.to_f / scores.size).round(precision)
  end

  private

  def gse_score_for(skill)
    score = public_send(:"#{skill}_score")
    return score if score.present?

    case public_send(:"#{skill}_code")
    when 'bl' then gse_range.begin
    when 'ns' then 0
    else 0
    end
  end
end
