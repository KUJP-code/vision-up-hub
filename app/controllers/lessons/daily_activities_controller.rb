# frozen_string_literal: true

class DailyActivitiesController < LessonsController
  def index
    @lessons = policy_scope(DailyActivity.order(title: :desc))
  end

  def create
    @lesson = authorize Lesson.new(daily_activity_params)
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
    return propose_changes(daily_activity_params) if proposing_changes?

    if @lesson.update(daily_activity_params)
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

  def daily_activity_params
    params.require(:daily_activity).permit(lesson_params + DailyActivity::ATTRIBUTES)
  end

  def after_update_url
    if params[:commit] == 'Change Date'
      course = daily_activity_params[:course_lessons_attributes]['0'][:course_id]
      course_url(course)
    else
      lesson_url(@lesson)
    end
  end
end
