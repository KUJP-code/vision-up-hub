# frozen_string_literal: true

module LessonConsumable
  extend ActiveSupport::Concern

  included do
    has_many :plans, through: :organisation
    has_many :courses, through: :plans
    has_many :course_lessons, through: :courses
    has_many :category_resources, through: :courses
    has_many :lessons, through: :courses

    delegate :available_tests, to: :organisation
    delegate :course_week, to: :organisation
    delegate :day_lessons, to: :organisation
  end
end
