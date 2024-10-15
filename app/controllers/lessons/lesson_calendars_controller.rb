# frozen_string_literal: true

class LessonCalendarsController < ApplicationController
  def index
    @date = Date.parse(params[:date] || Time.zone.now.beginning_of_week.to_s)
    @orgs = policy_scope(Organisation)
    @organisation = Organisation.find(params[:org] || current_user.organisation_id)
    authorize @organisation, :show?
    @course_lessons = @organisation.week_course_lessons(@date).includes(:lesson)
    @announcements = Pundit.policy_scope!(set_teacher, Announcement)
  end

  private

  def set_teacher
    return current_user if current_user.is?('Teacher')

    Teacher.new(organisation_id: @organisation.id, name: 'Example')
  end
end
