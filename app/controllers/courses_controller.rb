# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update]
  before_action :set_lessons, only: %i[new edit]

  def index
    @courses = Course.all
  end

  def show
    @lessons = @course.lessons.select(:id, :title, :type)
  end

  def new
    @course = Course.new
  end

  def edit; end

  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to @course
    else
      render :new,
             status: :unprocessable_entity,
             alert: 'Course could not be created'
    end
  end

  def update
    if @course.update(course_params)
      redirect_to @course
    else
      render :edit
    end
  end

  private

  def course_params
    params.require(:course).permit(
      :title, :description, :released,
      course_lessons_attributes: %i[id _destroy course_id day lesson_id week]
    )
  end

  def set_course
    @course = Course.find(params[:id])
  end

  def set_lessons
    @lessons = Lesson.pluck(:title, :id)
  end
end
