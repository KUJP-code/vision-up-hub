# frozen_string_literal: true

class MonthlyMaterialsController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :monthly_materials
    basic_data
    @month = selected_month
    @lesson_occurrences = lesson_occurrences
  end

  def show
    authorize :monthly_materials, :index?
    @lesson = policy_scope(Lesson).find(params[:id])
    @teacher = current_user
    @date = parsed_preview_date
    @level = @lesson.calendar_level
    @type = @lesson.type
    @type_lessons = Lesson.where(id: @lesson.id)
    @specialist_subtype = preview_specialist_subtype
    @resources = preview_resources
    @lesson_links = @specialist_subtype.present? ? [] : @lesson.lesson_links

    render 'teacher_lessons/show'
  end

  private

  def parsed_preview_date
    Date.parse(params[:date])
  rescue Date::Error, TypeError
    Time.zone.today
  end

  def preview_specialist_subtype
    return unless @lesson.is_a?(EveningClass) && @lesson.specialist_structured?
    return unless @lesson.specialist_subtypes_with_content.include?(params[:subtype])

    params[:subtype]
  end

  def preview_resources
    resources = if @specialist_subtype.present?
                  @lesson.specialist_resources_for(@specialist_subtype).includes(:blob)
                else
                  @lesson.resources_attachments.includes(:blob)
                end.to_a

    resources.concat(preview_phonics_resources)
    resources.sort_by { |resource| resource.blob.filename }
  end

  def preview_phonics_resources
    return [] unless @lesson.is_a?(PhonicsClass)

    course_lesson = @lesson.course_lessons.find_by(id: params[:course_lesson_id])
    return [] unless course_lesson

    @lesson.phonics_resources
           .for_course_week(course_lesson.course_id, course_lesson.week)
           .includes(:blob)
           .to_a
  end

  def query_params
    submitted_params = params.permit(:month, :org)
    submitted_params = params.require(:q).permit(:month, :org) if params[:q].present?

    if submitted_params[:month].blank?
      {
        month: Time.zone.today.strftime('%Y-%m'),
        org: @organisation&.id
      }.compact
    else
      submitted_params
    end
  end

  def basic_data
    if current_user.is?('Admin', 'Writer')
      @orgs = policy_scope(Organisation).order(:name)
      @organisation = selected_organisation
    else
      @organisation = current_user.organisation
    end
  end

  def lesson_occurrences
    return [] unless @organisation

    month_range = @month.all_month
    occurrences = @organisation.plans.flat_map { |plan| occurrences_for(plan, month_range) }

    occurrences.sort_by { |lesson, _course_lesson, date| [date, lesson.type, lesson.title] }
  end

  def occurrences_for(plan, month_range)
    lessons_for(plan, month_range).flat_map do |lesson|
      lesson.course_lessons.filter_map do |course_lesson|
        next unless course_lesson.course_id == plan.course_id

        date = occurrence_date(plan, course_lesson)
        [lesson, course_lesson, date] if month_range.cover?(date)
      end
    end
  end

  def lessons_for(plan, month_range)
    from_week = course_week(plan, month_range.begin)
    to_week = course_week(plan, month_range.end)
    return Lesson.none if to_week < 1 || from_week > 52

    policy_scope(Lesson)
      .where.not("lessons.purchase_materials = '[]'")
      .includes(:course_lessons)
      .where(course_lessons: {
               course_id: plan.course_id,
               week: [from_week, 1].max..[to_week, 52].min
             })
  end

  def selected_month
    Date.strptime("#{query_params[:month]}-01", '%Y-%m-%d')
  rescue Date::Error, TypeError
    Time.zone.today.beginning_of_month
  end

  def course_week(plan, date)
    (((date - plan.start.to_date).to_i + 1) / 7.0).ceil
  end

  def occurrence_date(plan, course_lesson)
    plan.start.to_date +
      (course_lesson.week - 1).weeks +
      CourseLesson.day_offset(course_lesson.day).days
  end

  def selected_organisation
    selected_id = params[:org].presence || params.dig(:q, :org).presence
    return @orgs.first if selected_id.blank?

    @orgs.find { |org| org.id == selected_id.to_i } || @orgs.first
  end
end
