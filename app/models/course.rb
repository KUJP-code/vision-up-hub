# frozen_string_literal: true

class Course < ApplicationRecord
  validates :title, presence: true

  has_many :course_lessons, dependent: :destroy
  accepts_nested_attributes_for :course_lessons,
                                reject_if: :all_blank,
                                allow_destroy: true
  has_many :lessons, through: :course_lessons
  has_many :plans, dependent: :destroy
  has_many :organisations, through: :plans
end
