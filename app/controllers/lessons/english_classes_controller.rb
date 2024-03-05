# frozen_string_literal: true

class EnglishClassesController < LessonsController
  skip_after_action :generate_guide

  def index
    @lessons = policy_scope(EnglishClass.order(title: :desc))
  end

  def create
    @lesson = authorize Lesson.new(english_class_params)
    super

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: 'English class successfully created!'
    else
      set_courses
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'English class could not be created'
    end
  end

  def update
    return propose_changes(english_class_params) if proposing_changes?

    if @lesson.update(english_class_params)
      redirect_to after_update_url,
                  notice: 'English class successfully updated.'
    else
      set_courses
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'English class could not be updated'
    end
  end

  private

  def english_class_params
    params.require(:english_class).permit(lesson_params + EnglishClass::ATTRIBUTES)
  end

  def after_update_url
    if params[:commit] == 'Change Date'
      course = english_class_params[:course_lessons_attributes]['0'][:course_id]
      course_url(course)
    else
      lesson_url(@lesson)
    end
  end
end
