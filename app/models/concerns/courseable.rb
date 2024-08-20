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

      query = lesson_query(date, :day)
      lessons.where(query[:string], *query[:conditions]).distinct
    end

    def week_lessons(date)
      return Lesson.none if plans.active.empty?

      query = lesson_query(date, :week)
      course_lessons.where(query[:string], *query[:conditions]).distinct
    end
  end

  private

  def lesson_query(date, period)
    day = date.strftime('%w').to_i + 1

    course_weeks =
      plans.active.map do |plan|
        { course_id: plan.course_id, day:, week: course_week(plan, date) }
      end

    build_query(course_weeks, period)
  end

  def build_query(course_weeks, period)
    result = { string: '', conditions: [] }
    course_weeks.each do |w|
      query_string = 'course_lessons.course_id = ? AND course_lessons.week = ?' \
                     "#{period == :day ? ' AND course_lessons.day = ?' : ''}"

      result[:string] = if result[:string].empty?
                          query_string
                        else
                          "#{result[:string]} OR #{query_string}"
                        end
      result[:conditions] = result[:conditions] + [w[:course_id], w[:week], w[:day]]
    end

    result
  end
end
