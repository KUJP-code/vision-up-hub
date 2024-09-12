# frozen_string_literal: true

class MonthlyMaterialsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :monthly_materials
    basic_data
    @from_week = if params[:q].blank?
                   current_week = Time.zone.today.beginning_of_week
                   current_user.course_week(current_user.plans.first,
                                            current_week)
                 else
                   query_params[:from_week].to_i
                 end

    @lessons = lessons_from_query(@from_week)
  end

  private

  def query_params
    if params[:q].blank?
      { course: current_user.courses.first }
    else
      params.require(:q).permit(:course, :from_week, :weeks_forward)
    end
  end

  def basic_data
    @courses = policy_scope(Course).pluck(:title, :id)
    course_plans = policy_scope(Course).includes(:plans)
    @plan_data = if current_user.is?('Admin')
                   course_plans.to_h { |c| [c.id, c.plan_date_data] }
                 else
                   course_plans.to_h do |c|
                     [c.id, c.plan_date_data(current_user.organisation_id)]
                   end
                 end
  end

  def lessons_from_query(from_week)
    @weeks_forward = query_params[:weeks_forward] ? query_params[:weeks_forward].to_i : 1
    @to_week = from_week + @weeks_forward

    policy_scope(Lesson)
      .where.not("lessons.materials = '[]'")
      .includes(:course_lessons)
      .where(course_lessons:
             { course_id: query_params[:course] })
      .where(course_lessons:
             { week: from_week..@to_week })
      .order('lessons.type ASC, course_lessons.week ASC,
             course_lessons.day ASC')
  end
end
