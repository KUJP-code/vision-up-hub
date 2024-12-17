# frozen_string_literal: true

class TeacherEventLessonsController < ApplicationController
  after_action :verify_authorized, only: %i[show]
  SUPPORTED_TYPES = %w[Seasonal Parties Events].freeze
  def index
    @teacher_event_lessons = Lesson.all
    @teacher_event_lessons = @teacher_event_lessons.where('start_time <= ? AND end_time >= ?', Time.current,
                                                          Time.current)
  end

  def show
    set_date_type_teacher
    @type = validated_type(params[:type])
    @type_lessons, @lesson = lessons_for_type(@teacher, @date, @type)
    @resources = set_resources
  end

  private

  def index_vars
    set_date_teacher
    @valid_types = SUPPORTED_TYPES
    @announcements = Pundit.policy_scope!(@teacher, Announcement)
    @lessons = fetch_lessons
  end

  def set_date_type_teacher
    @teacher = current_user.id
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
  end

  def fetch_lessons
    Lesson.where('show_from <=? AND show_until >= ?', @date, @date)
          .order(:event_date)
  end

  def validated_type(type_param)
    if SUPPORTED_TYPES.none?(type_param)
      redirect_back fallback_location: root_path, alert: "Invalid lesson type: #{type_param}"
    else
      type_param
    end
  end

  def lessons_for_type(teacher, date, type)
    type_lessons = teacher.day_lessons(date).where(type:).order(:title)
    lesson = params[:id].present? ? type_lessons.find(params[:id]) : type_lessons.first
    authorize lesson
    [type_lessons, lesson]
  end
end
