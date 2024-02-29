# frozen_string_literal: true

class StandShowSpeaksController < LessonsController
  skip_after_action :generate_guide

  def index
    @lessons = policy_scope(StandShowSpeak.all)
  end

  def create
    @lesson = authorize Lesson.new(stand_show_speak_params)
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
    return propose_changes(stand_show_speak_params) if proposing_changes?

    if @lesson.update(stand_show_speak_params)
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

  def stand_show_speak_params
    sss_params = %i[script]
    params.require(:stand_show_speak).permit(lesson_params + sss_params)
  end

  def after_update_url
    if params[:commit] == 'Change Date'
      course = stand_show_speak_params[:course_lessons_attributes]['0'][:course_id]
      course_url(course)
    else
      lesson_url(@lesson)
    end
  end
end
