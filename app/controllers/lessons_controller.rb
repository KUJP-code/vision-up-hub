# frozen_string_literal: true

class LessonsController < ApplicationController
  def new
    @lesson = Lesson.new(category: params[:category], course_id: params[:course_id])
    render "lessons/#{@lesson.category.pluralize}/new"
  end

  private

  def lesson_params
    params.require(:lesson).permit(:title, :summary, :category, :week, :day)
  end
end
