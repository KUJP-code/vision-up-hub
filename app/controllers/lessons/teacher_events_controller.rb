# frozen_string_literal: true

class TeacherEventsController < ApplicationController
  after_action :verify_authorized, only: %i[show]
  SUPPORTED_TYPES = %w[seasonalactivity partyactivity events].freeze
  def index
    index_vars
  end

  def show
    set_date_type_teacher
    @lesson =  authorize Lesson.find(params[:id])
    @resources = set_resources
  end

  private

  def index_vars
    set_date_type_teacher

    @supported_types = SUPPORTED_TYPES
    @announcements = Pundit.policy_scope!(@teacher, Announcement)
    @lessons =
      Lesson
      .where(type: %w[SeasonalActivity PartyActivity])
      .for_organisation(@teacher.organisation_id)
      .within_event_window(@date)
      .includes(:organisation_lessons)
      .order('organisation_lessons.event_date ASC')
      .then { |rel| policy_scope(rel) }

  end

  def set_date_type_teacher
    @teacher = current_user
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
  end

  def set_resources
    resources = @lesson.resources.includes(:blob)
    resources.sort_by { |r| r.blob.filename }
  end

  def validated_type(type_param)
    if SUPPORTED_TYPES.none?(type_param)
      redirect_back fallback_location: root_path, alert: "Invalid lesson type: #{type_param}"
    else
      type_param
    end
  end
end
