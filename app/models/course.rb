# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :course_lessons, dependent: :destroy
  accepts_nested_attributes_for :course_lessons
  has_many :lessons, through: :course_lessons
end
