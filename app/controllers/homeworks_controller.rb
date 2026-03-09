# frozen_string_literal: true

class HomeworksController < ApplicationController
  before_action :set_courses
  before_action :set_course
  after_action :verify_authorized

  def index
    authorize Lesson, :homework_index?
    return unless @course

    setup_level_grouped_homeworks
  end

  private

  def set_course
    @course = @courses.find_by(id: params[:course_id]) || @courses.first
  end

  def set_courses
    @courses = if current_user.is?('Admin', 'Writer')
                 Course.order(:title)
               else
                 policy_scope(Course).order(:title)
               end
  end

  def setup_level_grouped_homeworks
    return unless load_plan

    week_range = current_week_range(@plan)
    course_lessons = load_homework_for_weeks(week_range)

    @homeworks_grouped_by_level = course_lessons.group_by { |course_lesson| course_lesson.lesson.short_level }
    @short_levels = @homeworks_grouped_by_level.keys.sort_by { |lvl| level_sort_index(lvl) }

    if params[:level].blank? && @short_levels.present?
      redirect_to homeworks_path(course_id: @course.id, level: @short_levels.first) and return
    end

    selected_level = params[:level]
    @homework_resources = filter_and_sort_homework(@homeworks_grouped_by_level[selected_level])
  end

  def level_sort_index(level)
    ordered = ['Land', 'Sky', 'Galaxy', 'Keep Up', 'Specialist']
    ordered.index(level) || 999
  end

  def load_plan
    @plan = @course.plans
                   .where(organisation_id: current_user.organisation_id)
                   .where('start <= ? AND finish_date >= ?', Time.zone.today, Time.zone.today)
                   .first
  end

  def current_week_range(plan)
    current_week = ((Time.zone.today - plan.start.to_date).to_i / 7) + 1
    (current_week - 2..current_week + 2).to_a.select { |w| w.between?(1, 52) }
  end

  def load_homework_for_weeks(week_range)
    @course.course_lessons
           .joins(:lesson)
           .where(week: week_range, lessons: { type: 'EnglishClass' })
           .includes(lesson: [
                       { homework_sheet_attachment: :blob },
                       { homework_answers_attachment: :blob }
                     ])
           .select do |course_lesson|
      course_lesson.lesson.homework_sheet.attached? || course_lesson.lesson.homework_answers.attached?
    end
  end

  def filter_and_sort_homework(homeworks)
    return [] unless homeworks

    homeworks.sort_by(&:week)
  end
end
