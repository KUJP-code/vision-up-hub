# frozen_string_literal: true

class MissingLessonsController < ApplicationController
  after_action :verify_authorized

  def index
    @org = set_org
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @plans = @org.plans
    @course_lessons = CourseLesson.where(query_string(@plans, @date))
                                  .includes(:lesson)
  end

  private

  def set_org
    if params[:org_id]
      authorize Organisation.find(params[:organisation_id])
    else
      authorize current_user.organisation
    end
  end

  def query_string(plans, date)
    teacher = @org.teachers.first
    plans.map do |p|
      "course_lessons.course_id = #{p.course_id} AND course_lessons.week = #{teacher.course_week(p, date)}"
    end.join(' OR ')
  end
end
