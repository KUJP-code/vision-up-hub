# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[edit show update]
  after_action :save_guide, only: %i[create update]

  def show
    @course = @lesson.course
  end

  def new
    type = params[:type] if Lesson::TYPES.include?(params[:type])
    @lesson = type.constantize.new(course_id: params[:course_id])
  end

  def edit; end

  def create; end

  def update; end

  private

  def lesson_params
    %i[course_id day level summary title type week]
  end

  def save_guide
    @lesson.valid? && @lesson.save_guide
  end

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end
end
