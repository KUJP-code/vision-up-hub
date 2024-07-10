# frozen_string_literal: true

module Courseable
  extend ActiveSupport::Concern

  included do
    delegate :plan, to: :organisation
    delegate :course, to: :plan
    delegate :category_resources, to: :course
    delegate :lessons, to: :course

    def courses
      Course.where(id: plan.course_id)
    end

    def course_week(date)
      (((date - plan.start).to_i + 1) / 7.0).ceil
    end

    def day_lessons(date)
      return Lesson.none if plan.nil? || date > plan.finish_date

      day = date.strftime('%A').downcase
      week = course_week(date)
      lessons.released.where(course_lessons: { day:, week: })
    end
  end
end
