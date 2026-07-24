# frozen_string_literal: true

class MonthlyMaterialsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :monthly_materials
    basic_data
    @month = selected_month
    @lesson_occurrences = lesson_occurrences
  end

  private

  def query_params
    if params[:q].blank?
      {
        course: @courses.first&.last,
        month: Time.zone.today.strftime('%Y-%m'),
        org: @organisation&.id
      }.compact
    else
      params.require(:q).permit(:course, :month, :org)
    end
  end

  def basic_data
    if current_user.is?('Admin', 'Writer')
      @orgs = policy_scope(Organisation).order(:name)
      @organisation = selected_organisation
      course_plans = @organisation ? @organisation.courses.includes(:plans).distinct : Course.none
      @courses = course_plans.pluck(:title, :id)
    else
      @organisation = current_user.organisation
      @courses = policy_scope(Course).pluck(:title, :id)
    end
  end

  def lesson_occurrences
    plan = selected_plan
    return [] unless plan

    month_range = @month.all_month
    occurrences = lessons_for(plan, month_range).flat_map do |lesson|
      lesson.course_lessons.filter_map do |course_lesson|
        date = occurrence_date(plan, course_lesson)
        [lesson, course_lesson, date] if month_range.cover?(date)
      end
    end

    occurrences.sort_by { |lesson, _course_lesson, date| [date, lesson.type, lesson.title] }
  end

  def lessons_for(plan, month_range)
    from_week = course_week(plan, month_range.begin)
    to_week = course_week(plan, month_range.end)
    return Lesson.none if to_week < 1 || from_week > 52

    policy_scope(Lesson)
      .where.not("lessons.materials = '[]'")
      .includes(:course_lessons)
      .where(course_lessons: {
               course_id: plan.course_id,
               week: [from_week, 1].max..[to_week, 52].min
             })
  end

  def selected_month
    Date.strptime("#{query_params[:month]}-01", '%Y-%m-%d')
  rescue Date::Error, TypeError
    Time.zone.today.beginning_of_month
  end

  def selected_plan
    return if query_params[:course].blank? || @organisation.blank?

    @organisation.plans.find_by(course_id: query_params[:course])
  end

  def course_week(plan, date)
    (((date - plan.start.to_date).to_i + 1) / 7.0).ceil
  end

  def occurrence_date(plan, course_lesson)
    plan.start.to_date +
      (course_lesson.week - 1).weeks +
      (CourseLesson.days.fetch(course_lesson.day) - CourseLesson.days.fetch('monday')).days
  end

  def selected_organisation
    selected_id = params[:org].presence || params.dig(:q, :org).presence
    return @orgs.first if selected_id.blank?

    @orgs.find { |org| org.id == selected_id.to_i } || @orgs.first
  end
end
