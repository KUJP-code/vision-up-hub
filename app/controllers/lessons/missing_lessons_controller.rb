# frozen_string_literal: true

class MissingLessonsController < ApplicationController
  after_action :verify_authorized

  def index
    @date = Date.parse(params[:date] || 7.days.from_now.beginning_of_week.to_s)
    @orgs, @org = set_orgs
    @plans = @org.plans
    @course_lessons = CourseLesson.where(query_string(@org, @plans, @date))
                                  .includes(:lesson).where(lesson: { released: true })
  end

  private

  def set_orgs
    @orgs = policy_scope(Organisation)
    @org = if params[:org_id]
             authorize Organisation.find(params[:organisation_id])
           else
             authorize @orgs.first
           end

    [@orgs, @org]
  end

  def query_string(org, plans, date)
    plan_queries = plans.map do |p|
      "course_lessons.course_id = #{p.course_id} AND course_lessons.week = #{org.course_week(p, date)}"
    end

    plan_queries.join(' OR ')
  end
end
