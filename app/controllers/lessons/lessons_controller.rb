# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[edit show update]
  before_action :set_courses, only: %i[new edit]
  after_action :save_guide, only: %i[create update]

  def show
    @courses = @lesson.courses
  end

  def new
    type = params[:type] if Lesson::TYPES.include?(params[:type])
    @lesson = type.constantize.new
  end

  def edit; end

  def create
    dummy_route
  end

  def update
    dummy_route
  end

  private

  def lesson_params
    [:day, :level, :summary, :title, :type, :week,
     { course_lessons_attributes: %i[id course_id lesson_id _destroy] }]
  end

  def dummy_route
    redirect_to root_url,
                alert: 'This route should be overwritten when inherited'
  end

  def save_guide
    @lesson.valid? && @lesson.save_guide
  end

  def set_courses
    @courses = Course.pluck(:name, :id)
  end

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end
end
