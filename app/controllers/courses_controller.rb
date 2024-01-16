# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update]

  def index
    @courses = Course.all
  end

  def show; end

  def edit; end

  def update
    if @course.update(course_params)
      redirect_to @course
    else
      render :edit
    end
  end

  private

  def course_params
    params.require(:course).permit(:name, :root_path, :description, :public)
  end

  def set_course
    @course = Course.find(params[:id])
  end
end
