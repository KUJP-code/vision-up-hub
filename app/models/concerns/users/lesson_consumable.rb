# frozen_string_literal: true

module LessonConsumable
  extend ActiveSupport::Concern

  included do
    has_many :plans, through: :organisation
    has_many :courses, through: :plans
    has_many :category_resources, through: :courses
    has_many :lessons, through: :courses

    delegate :day_lessons, to: :organisation
  end
end
