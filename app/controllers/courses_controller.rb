# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update]

  def index
    @courses = Course.all
  end

  def show
    @path = params[:path].presence || @course.root_path
    @files = ActiveStorage::Blob.where('key LIKE ?', "%#{@path}%")
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
    params.require(:course).permit(:name, :root_path, :description, :released)
  end

  def set_course
    @course = Course.find(params[:id])
  end
end
