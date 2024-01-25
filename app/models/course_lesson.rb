# frozen_string_literal: true

class CourseLesson < ApplicationRecord
  belongs_to :course, inverse_of: :course_lessons
  belongs_to :lesson, inverse_of: :course_lessons
end
