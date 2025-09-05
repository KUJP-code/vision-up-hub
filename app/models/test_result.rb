# frozen_string_literal: true

class TestResult < ApplicationRecord
  # Basics max is hardcoded due to how tests were initially set up, when there's time to refactor the entire thing we can do that
  BASICS_MAX = 2
  include Levels

  store_accessor :answers, :listening
  store_accessor :answers, :reading
  store_accessor :answers, :speaking
  store_accessor :answers, :writing

  enum :new_level, LEVELS, suffix: true
  enum :prev_level, LEVELS, prefix: true

  before_validation :scores_to_int, :set_grade, :prevent_evening
  after_save :update_student_level

  belongs_to :test
  belongs_to :student
  delegate :organisation_id, to: :student

  validate :reason_given?
  validates :new_level, :prev_level, :total_percent, presence: true
  validates :listen_percent, :read_percent,
            :speak_percent, :total_percent,
            :write_percent, numericality:
            { allow_nil: true, only_integer: true,
              greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  acts_as_copy_target

  def radar_data
    { label: test.name,
      data: [read_percent || 0,
             write_percent || 0,
             listen_percent || 0] }
  end

  def recommended_level
    current_level = { level: prev_level, percent: 0 }
    rec = test.thresholds.reduce(current_level) do |recommended, threshold|
      level, percent = threshold
      next recommended if recommended[:percent] > percent ||
                          percent > total_percent

      { level: level.downcase.tr(' ', '_'), percent: }
    end
    rec[:level] = 'galaxy_two' if EVENING_COURSES.include?(rec[:level])

    rec[:level]
  end

  def reading_total
    (test.questions['reading'] || []).sum
  end

  def writing_total
    (test.questions['writing'] || []).sum
  end

  def listening_total
    (test.questions['listening'] || []).sum
  end

  def basics_percent
    basics_max = 2
    (basics.to_f / basics_max * 100).round
  end

  def max_score
    (test.questions['reading']   || []).sum +
    (test.questions['writing']   || []).sum +
    (test.questions['listening'] || []).sum +
    BASICS_MAX
  end

  def total_score 
    answers.values.flatten.sum + basics
  end

  def total_score_ratio
    return 0 if max_score.zero?
    total_score.to_f / max_score
  end

  def total_score_total
    "#{total_score} / #{max_score}"
  end

  def test_print_percent
    (total_score_ratio * 100).round
  end

  private

  def prevent_evening
    self.new_level = 'galaxy_two' if EVENING_COURSES.include?(new_level)
  end

  def reason_given?
    return true unless reason.blank? && new_level != recommended_level

    errors.add(:reason,
               I18n.t('test_results.errors.reason_required'))
  end

  def scores_to_int
    answers.transform_values! { |answers| answers.map(&:to_i) }
  end

  def set_grade
    return if grade.present?

    self.grade = student.grade
  end

  def update_student_level
    return if student && ::Levels::EVENING_COURSES.include?(student.level)

    self.new_level = 'galaxy_two' if EVENING_COURSES.include?(new_level)

    student.update!(level: new_level)
  end
end