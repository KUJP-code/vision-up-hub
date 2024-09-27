# frozen_string_literal: true

class TeacherLessonsController < ApplicationController
  after_action :verify_authorized, only: %i[show]

  def index
    respond_to do |format|
      format.turbo_stream { index_vars }
    end
  end

  def show
    set_date_level_teacher
    @type = validated_type(params[:type])
    @type_lessons, @lesson = lessons_for_type(@teacher, @date, @level, @type)
    @resources = set_resources
  end

  private

  def index_vars
    set_date_level_teacher
    @types = @teacher.day_lessons(@date)
                     .send(@level).pluck(:type).uniq
    @announcements = Pundit.policy_scope!(@teacher, Announcement)
  end

  def set_date_level_teacher
    @teacher = Teacher.find(params[:teacher_id])
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @level = validated_level(params[:level], @teacher)
  end

  def set_resources
    resources = @lesson.resources.includes(:blob)
    resources += phonics_resources if @type == 'PhonicsClass'

    resources.sort_by { |r| r.blob.filename }
  end

  def phonics_resources
    # TODO: Must be a better way to do this
    course_lesson = @teacher.course_lessons.find_by(lesson_id: @lesson.id)
    plan = @teacher.plans.find_by(course_id: course_lesson.course_id)
    week = @teacher.course_week(plan, @date)
    @lesson.phonics_resources.where(week:).includes(:blob)
  end

  def validated_level(level_param, teacher)
    @valid_levels = %w[kindy elementary keep_up specialist]
                    .select { |level| Flipper.enabled?(:"#{level}", teacher) }
    if @valid_levels.none?(level_param)
      return redirect_back fallback_location: root_path,
                           alert: "Invalid level: #{level_param}"
    end

    level_param
  end

  def validated_type(type_param)
    if Lesson::TYPES.none?(type_param)
      return redirect_back fallback_location: root_path,
                           alert: "Invalid level: #{type_param}"
    end

    type_param
  end

  def lessons_for_type(teacher, date, level, type)
    type_lessons = teacher.day_lessons(date)
                          .send(level).where(type:)
                          .order(level: :asc)
    lesson = if params[:id].to_i.zero?
               authorize type_lessons.first
             else
               authorize type_lessons.find(params[:id])
             end

    [type_lessons, lesson]
  end
end
