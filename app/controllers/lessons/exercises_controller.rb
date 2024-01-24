# frozen_string_literal: true

class ExercisesController < ApplicationController
  include LessonParams

  after_action :save_guide, only: %i[create update]

  def create
    course = Course.find(params[:course_id])
    @exercise = course.lessons.new(exercise_params)

    if @exercise.save
      redirect_to course_lesson_url(course, @exercise),
                  notice: 'Exercise was successfully created.'
    else
      @lesson = @exercise
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Exercise could not be created'
    end
  end

  def update
    @exercise = Lesson.find(params[:id])

    if @exercise.update(exercise_params)
      redirect_to course_lesson_url(@exercise.course, @exercise),
                  notice: 'Exercise was successfully updated.'
    else
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Exercise could not be updated'
    end
  end

  private

  def exercise_params
    e_params = %i[links]
    params.require(:exercise).permit(lesson_params + e_params)
  end

  def save_guide
    @exercise.save_guide
  end
end
