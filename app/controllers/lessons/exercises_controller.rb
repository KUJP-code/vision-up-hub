# frozen_string_literal: true

class ExercisesController < LessonsController
  def create
    course = Course.find(params[:course_id])
    @lesson = course.lessons.new(exercise_params)

    if @lesson.save
      redirect_to course_lesson_url(course, @lesson),
                  notice: 'Exercise was successfully created.'
    else
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Exercise could not be created'
    end
  end

  def update
    if @lesson.update!(exercise_params)
      redirect_to course_lesson_url(@lesson.course, @lesson),
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
end
