# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[destroy edit show update]
  before_action :set_courses, only: %i[new edit]
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]
  after_action :generate_guide, only: %i[create update]

  def index
    @lessons = policy_scope(Lesson.all)
  end

  def show
    @courses = @lesson.courses
  end

  def new
    type = params[:type] if Lesson::TYPES.include?(params[:type])
    @lesson = authorize type.constantize.new
  end

  def edit; end

  def create
    @lesson.guide.purge
  end

  def update
    @lesson.guide.purge
  end

  def destroy
    if @lesson.destroy
      redirect_to lessons_path,
                  notice: 'Lesson was successfully destroyed.'
    else
      redirect_to lessons_path,
                  alert: "Lesson could not be destroyed. Check it's not still in use"
    end
  end

  private

  GUIDE_DELAY = "\nNew guide may take up to 10s to generate, refresh the page to check."

  def lesson_params
    [:goal, :level, :title, :type,
     { course_lessons_attributes:
       %i[id _destroy course_id day lesson_id week] }]
  end

  def dummy_route
    redirect_to root_url,
                alert: 'This route should be overwritten when inherited'
  end

  def set_courses
    @courses = Course.pluck(:title, :id)
  end

  def set_lesson
    @lesson = authorize Lesson.find(params[:id])
  end

  def generate_guide
    return if @lesson.new_record?

    @lesson.attach_guide
  end
end
