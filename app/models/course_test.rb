# frozen_string_literal: true

class CourseTest < ApplicationRecord
  validates :week, presence: true
  validates :week, numericality: { only_integer: true }
  validates :week, comparison: { greater_than: 0, less_than: 53 }

  belongs_to :course, inverse_of: :course_tests
  belongs_to :test, inverse_of: :course_tests
end
