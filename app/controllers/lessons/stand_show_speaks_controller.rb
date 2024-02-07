# frozen_string_literal: true

class StandShowSpeaksController < LessonsController
  skip_after_action :queue_guide_generation

  def index
    @lessons = policy_scope(StandShowSpeak.all)
  end

  def create
    @lesson = authorize Lesson.new(stand_show_speak_params)

    if @lesson.save!
      redirect_to lesson_url(@lesson),
                  notice: "Stand Show Speak successfully created! #{GUIDE_DELAY}"
    else
      set_courses
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Stand Show Speak could not be created'
    end
  end

  def update
    if @lesson.update(stand_show_speak_params)
      redirect_to lesson_url(@lesson),
                  notice: "Stand Show Speak successfully updated. #{GUIDE_DELAY}"
    else
      set_courses
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Stand Show Speak could not be updated'
    end
  end

  private

  def stand_show_speak_params
    sss_params = %i[script]
    params.require(:stand_show_speak).permit(lesson_params + sss_params)
  end
end
