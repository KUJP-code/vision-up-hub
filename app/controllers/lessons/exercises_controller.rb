# frozen_string_literal: true

class ExercisesController < LessonsController
  def index
    @lessons = Exercise.order(title: :desc)
  end

  def create
    @lesson = authorize Lesson.new(exercise_params)

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: "Exercise successfully created. #{GUIDE_DELAY}"
    else
      set_courses
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Exercise could not be created'
    end
  end

  def update
    if @lesson.update!(exercise_params)
      redirect_to lesson_url(@lesson),
                  notice: "Exercise was successfully updated. #{GUIDE_DELAY}"
    else
      set_courses
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Exercise could not be updated'
    end
  end

  private

  def exercise_params
    e_params = %i[
      add_difficulty extra_fun instructions intro large_groups
      links materials notes outro steps guide_image
    ]
    params.require(:exercise).permit(lesson_params + e_params)
  end
end
