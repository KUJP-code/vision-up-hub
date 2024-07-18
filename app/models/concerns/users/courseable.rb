# frozen_string_literal: true

module Courseable
  extend ActiveSupport::Concern

  included do
    belongs_to :organisation
    has_many :plans, through: :organisation
    has_many :courses, through: :plans
    has_many :course_lessons, through: :courses
    has_many :category_resources, through: :courses
    has_many :lessons, through: :courses

    def course_week(plan, date)
      (((date - plan.start).to_i + 1) / 7.0).ceil
    end

    def day_lessons(date)
      return Lesson.none if plans.empty? || plans.all?(&:finished?)

      lessons.where(query_string(date))
    end
  end

  def query_string(date)
    day = date.strftime('%w').to_i + 1
    course_weeks =
      plans.reject(&:finished?)
           .map { |plan| { course_id: plan.course_id, day:, week: course_week(plan, date) } }

    course_weeks.map do |w|
      course_cond = "course_lessons.course_id = #{w[:course_id]}"
      day_cond = "course_lessons.day = #{w[:day]}"
      week_cond = "course_lessons.week = #{w[:week]}"

      "#{course_cond} AND #{day_cond} AND #{week_cond}"
    end.join(' OR ')
  end
end
