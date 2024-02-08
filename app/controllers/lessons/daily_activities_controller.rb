# frozen_string_literal: true

class DailyActivitiesController < LessonsController
  def index
    @lessons = policy_scope(DailyActivity.all)
  end

  def create
    @lesson = authorize Lesson.new(daily_activity_params)

    if @lesson.save!
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
    if @lesson.update(daily_activity_params)
      redirect_to lesson_url(@lesson),
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
    da_params = %i[extra_fun intro instructions large_groups materials notes links steps subtype]
    params.require(:daily_activity).permit(lesson_params + da_params)
  end
end
