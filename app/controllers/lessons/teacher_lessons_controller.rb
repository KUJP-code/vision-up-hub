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
    return if performed?

    @type = validated_type(params[:type])
    return if performed?

    @subtype = validated_subtype(params[:subtype], @type, @level)
    return if performed?

    @type_lessons, @lesson = lessons_for_type(@teacher, @date, @level, @type, @subtype)
    @resources = set_resources
    @lesson_links = set_links
  end

  private

  def index_vars
    set_date_level_teacher
    @day_lessons = @teacher.day_lessons(@date).send(@level)
    @announcements = Pundit.policy_scope!(@teacher, Announcement)
  end

  def set_date_level_teacher
    @teacher = Teacher.find(params[:teacher_id])
    @date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
    @level = validated_level(params[:level], @teacher)
  end

  def set_resources
    resources = @lesson.resources_attachments.includes(:blob)
    resources += phonics_resources if @type == 'PhonicsClass'

    resources.sort_by { |r| r.blob.filename }
  end

  def set_links
    @lesson.lesson_links
  end

  def phonics_resources
    course_lesson = @teacher.course_lessons.find_by(lesson_id: @lesson.id)
    return PhonicsResource.none unless course_lesson

    plan = @teacher.plans.find_by(course_id: course_lesson.course_id)
    return PhonicsResource.none unless plan

    week = @teacher.course_week(plan, @date)

    @lesson.phonics_resources
           .for_course_week(course_lesson.course_id, week)
           .includes(:blob)
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

  def validated_subtype(subtype_param, type, level)
    return if subtype_param.blank? || type != 'EveningClass'

    if EveningClass.subtypes_for(level).exclude?(subtype_param)
      return redirect_back fallback_location: root_path,
                           alert: "Invalid subtype: #{subtype_param}"
    end

    subtype_param
  end

  def lessons_for_type(teacher, date, level, type, subtype = nil)
    type_lessons = teacher.day_lessons(date).send(level).where(type:)
    type_lessons = type_lessons.where(subtype: EveningClass.subtypes.fetch(subtype)) if subtype.present?
    type_lessons = type_lessons.order(level: :asc)

    if keep_up_evening_class?(level, type)
      first_lesson = type_lessons.first
      return [type_lessons.none, nil] unless first_lesson

      return [type_lessons.where(id: first_lesson.id), authorize(first_lesson)]
    end

    lesson = if params[:id].to_i.zero?
               authorize type_lessons.first
             else
               authorize type_lessons.find(params[:id])
             end

    [type_lessons, lesson]
  end

  def keep_up_evening_class?(level, type)
    level == 'keep_up' && type == 'EveningClass'
  end
end
