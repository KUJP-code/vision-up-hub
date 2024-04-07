# frozen_string_literal: true

class DailyActivitiesController < LessonsController
  def index
    @lessons = policy_scope(DailyActivity.order(title: :desc))
  end

  def create
    @lesson = authorize Lesson.new(type_params)
    super

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: 'Daily Activity successfully created!'
    else
      set_courses
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Daily activity could not be created'
    end
  end

  def update
    return propose_changes(type_params) if proposing_changes?

    attrs = super
    if @lesson.update(attrs)
      redirect_to after_update_url,
                  notice: 'Daily activity successfully updated.'
    else
      set_courses
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Daily activity could not be updated'
    end
  end

  private

  def type_params
    params.require(:daily_activity).permit(lesson_params + DailyActivity::ATTRIBUTES)
  end
end
