# frozen_string_literal: true

class PhonicsClassesController < LessonsController
  def index
    @lessons = policy_scope(PhonicsClass.all)
  end

  def create
    @lesson = authorize Lesson.new(phonics_class_params)
    super

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: 'Phonics Class successfully created!'
    else
      set_courses
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Phonics Class could not be created'
    end
  end

  def update
    return propose_changes(phonics_class_params) if proposing_changes?

    if @lesson.update(phonics_class_params)
      redirect_to after_update_url,
                  notice: 'Phonics Class successfully updated.'
    else
      set_courses
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Phonics Class could not be updated'
    end
  end

  private

  def phonics_class_params
    pc_params = %i[add_difficulty extra_fun instructions links materials notes]
    params.require(:phonics_class).permit(lesson_params + pc_params)
  end

  def after_update_url
    if params[:commit] == 'Change Date'
      course = phonics_class_params[:course_lessons_attributes]['0'][:course_id]
      course_url(course)
    else
      lesson_url(@lesson)
    end
  end
end
