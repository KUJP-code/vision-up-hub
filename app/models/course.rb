# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :course_lessons, dependent: :destroy
  has_many :lessons, through: :course_lessons
end
