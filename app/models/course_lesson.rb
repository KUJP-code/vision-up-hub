# frozen_string_literal: true

class CourseLesson < ApplicationRecord
  validates :week, :day, presence: true
  validates :week, numericality: { only_integer: true }
  validates :week, comparison: { greater_than: 0, less_than: 53 }

  enum day: {
    sunday: 1,
    monday: 2,
    tuesday: 3,
    wednesday: 4,
    thursday: 5,
    friday: 6,
    saturday: 7
  }

  belongs_to :course, inverse_of: :course_lessons
  belongs_to :lesson, inverse_of: :course_lessons
end
