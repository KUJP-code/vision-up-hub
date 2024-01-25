# frozen_string_literal: true

class DailyActivitiesController < LessonsController
  def index
    @lessons = DailyActivity.all
  end

  def create
    @lesson = Lesson.new(daily_activity_params)

    if @lesson.save
      redirect_to lesson_url(@lesson),
                  notice: 'Daily activity was successfully created.'
    else
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Daily activity could not be created'
    end
  end

  def update
    if @lesson.update(daily_activity_params)
      redirect_to lesson_url(@lesson),
                  notice: 'Daily activity was successfully updated.'
    else
      render 'lessons/edit',
             status: :unprocessable_entity,
             alert: 'Daily activity could not be updated'
    end
  end

  private

  def daily_activity_params
    da_params = %i[links steps subtype]
    params.require(:daily_activity).permit(lesson_params + da_params)
  end
end
