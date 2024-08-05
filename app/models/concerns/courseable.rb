# frozen_string_literal: true

module Courseable
  extend ActiveSupport::Concern

  included do
    def available_tests
      date = Time.zone.today
      course_weeks = plans.active.map { |p| [p.course_id, course_week(p, date)] }
      query_string = course_weeks.map do |course_id, week|
        "course_tests.course_id = #{course_id} AND course_tests.week <= #{week}"
      end.join(' OR ')

      Test.joins(:course_tests).where(query_string)
    end

    def course_week(plan, date)
      (((date - plan.start).to_i + 1) / 7.0).ceil
    end

    def day_lessons(date)
      return Lesson.none if plans.active.empty?

      lessons.where(query_string(date))
    end
  end

  def query_string(date)
    day = date.strftime('%w').to_i + 1
    course_weeks =
      plans.active
           .map { |plan| { course_id: plan.course_id, day:, week: course_week(plan, date) } }

    course_weeks.map do |w|
      course_cond = "course_lessons.course_id = #{w[:course_id]}"
      day_cond = "course_lessons.day = #{w[:day]}"
      week_cond = "course_lessons.week = #{w[:week]}"

      "#{course_cond} AND #{day_cond} AND #{week_cond}"
    end.join(' OR ')
  end
end
