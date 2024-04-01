# frozen_string_literal: true

class ExercisesController < LessonsController
  def index
    @lessons = policy_scope(Exercise.order(title: :desc))
  end

  def create
    @lesson = authorize Lesson.new(type_params)
    super

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: 'Exercise successfully created.'
    else
      set_courses
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Exercise could not be created'
    end
  end

  def update
    return propose_changes(type_params) if proposing_changes?

    if @lesson.update(type_params)
      redirect_to after_update_url,
                  notice: 'Exercise was successfully updated.'
    else
      set_courses
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Exercise could not be updated'
    end
  end

  private

  def type_params
    params.require(:exercise).permit(lesson_params + Exercise::ATTRIBUTES)
  end
end
