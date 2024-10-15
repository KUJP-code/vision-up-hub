# frozen_string_literal: true

class LessonCalendarsController < ApplicationController
  def index
    @date = Date.parse(params[:date] || Time.zone.now.beginning_of_week.to_s)
    @orgs = policy_scope(Organisation)
    @organisation = Organisation.find(params[:org] || current_user.organisation_id)
    authorize @organisation, :show?
    @course_lessons = @organisation.week_course_lessons(@date).includes(:lesson)
    @announcements = policy_scope(Announcement)
  end
end
