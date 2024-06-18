# frozen_string_literal: true

class LessonVersionsController < ApplicationController
  before_action :set_lesson, only: %i[show update]
  after_action :verify_authorized, only: %i[show update]

  def show
    @prev_version_id = @lesson.log_version - 1
    @diff = @lesson.diff_from(version: @prev_version_id)['changes']
  end

  def update
    if @lesson.undo!
      @lesson.attach_guide
      redirect_to lesson_url(@lesson),
                  notice: 'Reverted to previous version'
    else
      redirect_to lesson_url(@lesson),
                  alert: 'Could not revert to previous version'
    end
  end

  private

  def set_lesson
    @lesson = authorize Lesson.find(params[:id])
    @lesson.reload_log_data
  end
end
