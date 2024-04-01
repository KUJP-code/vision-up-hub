# frozen_string_literal: true

class StandShowSpeaksController < LessonsController
  skip_after_action :generate_guide

  def index
    @lessons = policy_scope(StandShowSpeak.order(title: :desc))
  end

  def create
    @lesson = authorize Lesson.new(type_params)
    super

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: "#{@lesson.title} successfully created!"
    else
      set_courses
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: "#{@lesson.title} could not be created"
    end
  end

  def update
    return propose_changes(type_params) if proposing_changes?

    if @lesson.update(type_params)
      redirect_to after_update_url,
                  notice: "#{@lesson.title} successfully updated."
    else
      set_courses
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: "#{@lesson.title} could not be updated"
    end
  end

  private

  def type_params
    params.require(:stand_show_speak).permit(lesson_params + StandShowSpeak::ATTRIBUTES)
  end
end
