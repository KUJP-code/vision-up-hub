# frozen_string_literal: true

class MonthlyMaterialsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :monthly_materials
    basic_data
    if params[:q].blank?
      next_week = Date.parse(7.days.from_now.to_s)
      @from_week = current_user.course_week(current_user.plans.first,
                                            next_week)
    else
      @lessons = lessons_from_query
    end
  end

  private

  def query_params
    params.require(:q).permit(:course, :from_week, :weeks_forward)
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

  def lessons_from_query
    stop_week =
      query_params[:from_week].to_i + query_params[:weeks_forward].to_i

    policy_scope(Lesson)
      .where.not("lessons.materials = '[]'")
      .includes(:course_lessons)
      .where(course_lessons:
             { course_id: query_params[:course] })
      .where(course_lessons:
             { week: query_params[:from_week].to_i..stop_week })
      .order('lessons.type ASC, course_lessons.week ASC,
             course_lessons.day ASC')
  end
end
