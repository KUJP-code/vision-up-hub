# frozen_string_literal: true

class DailyActivitiesController < ApplicationController
  include LessonParams

  after_action :save_guide, only: %i[create update]

  def create
    course = Course.find(params[:course_id])
    @daily_activity = course.lessons.new(daily_activity_params)

    if @daily_activity.save
      redirect_to course_lesson_url(course, @daily_activity),
                  notice: 'Daily activity was successfully created.'
    else
      @lesson = @daily_activity
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Daily activity could not be created'
    end
  end

  def update
    @daily_activity = Lesson.find(params[:id])

    if @daily_activity.update(daily_activity_params)
      redirect_to course_lesson_url(@daily_activity.course, @daily_activity),
                  notice: 'Daily activity was successfully updated.'
    else
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Daily activity could not be updated'
    end
  end

  private

  def daily_activity_params
    da_params = %i[links steps subtype]
    params.require(:daily_activity).permit(lesson_params + da_params)
  end

  def save_guide
    @daily_activity.save_guide
  end
end
