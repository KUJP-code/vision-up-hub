# frozen_string_literal: true

class SpecialLessonsController < LessonsController
  skip_after_action :generate_guide

  def index
    @lessons = policy_scope(SpecialLesson.order(title: :desc))
  end

  def create
    @lesson = authorize Lesson.new(type_params)
    super

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: 'Special lesson successfully created!'
    else
      p @lesson.errors
      set_form_info
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Special lesson could not be created'
    end
  end

  def update
    return propose_changes(type_params) if proposing_changes?

    attrs = super
    if @lesson.update(attrs)
      redirect_to after_update_url,
                  notice: 'Special lesson successfully updated.'
    else
      set_form_info
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Special lesson could not be updated'
    end
  end

  private

  def type_params
    params.require(:special_lesson).permit(
      lesson_params + SpecialLesson::ATTRIBUTES
    )
  end
end
