# frozen_string_literal: true

class DailyActivitiesController < LessonsController
  def create
    course = Course.find(params[:course_id])
    @lesson = course.lessons.new(daily_activity_params)

    if @lesson.save
      redirect_to course_lesson_url(course, @lesson),
                  notice: 'Daily activity was successfully created.'
    else
      render 'lessons/new',
             status: :unprocessable_entity,
             alert: 'Daily activity could not be created'
    end
  end

  def update
    @lesson = Lesson.find(params[:id])

    if @lesson.update(daily_activity_params)
      redirect_to course_lesson_url(@lesson.course, @lesson),
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
