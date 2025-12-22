# frozen_string_literal: true

class CourseLessonUploadsController < ApplicationController
  include SampleCsvable

  after_action :verify_authorized, only: %i[create new show]

  def show
    authorize nil, policy_class: CourseLessonUploadPolicy
    send_data sample_csv(CourseLesson::CSV_HEADERS),
              filename: 'sample_course_lessons_upload.csv'
  end

  def new
    authorize nil, policy_class: CourseLessonUploadPolicy
    @course = authorize Course.find(params[:course_id])
    @courses = policy_scope(Course)
  end

  def create
    authorize nil, policy_class: CourseLessonUploadPolicy
    @course = authorize Course.find(params[:course_id])
    @course_lesson = CourseLesson.new(course_lesson_upload_params.merge(course_id: @course.id))
    @index = params[:index].to_i
    @status = 'Uploaded'
    return set_errors('Course lesson already exists.') if duplicate_course_lesson?
    return if @course_lesson.save

    set_errors
  end

  private

  def course_lesson_upload_params
    params.require(:course_lesson_upload).permit(CourseLesson::CSV_HEADERS.map(&:to_sym))
  end

  def duplicate_course_lesson?
    return false if @course_lesson.lesson_id.blank?

    CourseLesson.exists?(
      course_id: @course.id,
      lesson_id: @course_lesson.lesson_id,
      week: @course_lesson.week,
      day: @course_lesson.day
    )
  end

  def set_errors(message = nil)
    @course_lesson.errors.add(:base, message) if message
    @errors = @course_lesson.errors.full_messages.to_sentence
    @status = 'Error'
  end
end
