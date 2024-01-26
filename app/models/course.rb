# frozen_string_literal: true

class Course < ApplicationRecord
  has_many :course_lessons, dependent: :destroy
  accepts_nested_attributes_for :course_lessons,
                                reject_if: :all_blank,
                                allow_destroy: true
  has_many :lessons, through: :course_lessons
end
