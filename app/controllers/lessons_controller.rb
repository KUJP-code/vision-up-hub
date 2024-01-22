# frozen_string_literal: true

class LessonsController < ApplicationController
  def new
    type = params[:type] if Lesson::TYPES.include?(params[:type])
    @lesson = type.constantize.new(course_id: params[:course_id])
  end
end
