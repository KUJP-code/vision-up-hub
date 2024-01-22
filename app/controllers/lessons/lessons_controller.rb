# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[edit show]

  def show
    @course = @lesson.course
  end

  def new
    type = params[:type] if Lesson::TYPES.include?(params[:type])
    @lesson = type.constantize.new(course_id: params[:course_id])
  end

  def edit; end

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end
end
