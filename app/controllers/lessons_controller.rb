# frozen_string_literal: true

class LessonsController < ApplicationController
  def new
    type = params[:type] if Lesson::TYPES.include?(params[:type])
    @lesson = type.constantize.new(course_id: params[:course_id])
    render "lessons/#{type.pluralize.underscore}/new"
  end

  private

  def lesson_params
    params.require(:lesson).permit(:title, :summary, :week, :day)
  end
end
