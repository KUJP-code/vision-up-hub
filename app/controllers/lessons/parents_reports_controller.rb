# frozen_string_literal: true

class ParentsReportsController < LessonsController
  skip_after_action :generate_guide

  def index
    @lessons = policy_scope(ParentsReport.order(title: :desc))
  end

  def create
    @lesson = authorize Lesson.new(type_params)
    super

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: 'Parents Report successfully created!'
    else
      set_form_data
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Parents Report could not be created'
    end
  end

  def update
    return propose_changes(type_params) if proposing_changes?

    attrs = super
    if @lesson.update(attrs)
      redirect_to after_update_url,
                  notice: 'Parents Report successfully updated.'
    else
      set_form_data
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Parents Report could not be updated'
    end
  end

  private

  def type_params
    params.require(:parents_report).permit(lesson_params + ParentsReport::ATTRIBUTES)
  end
end
