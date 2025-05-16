class HomeworksController < ApplicationController
  before_action :set_courses
  before_action :set_course, only: %i[index new create destroy]
  before_action :set_homework, only: %i[destroy]
  after_action :verify_policy_scoped, only: %i[index]
  after_action :verify_authorized, except: %i[index]

  def index
    @homeworks = if @course
      @course.homeworks.includes(:questions_attachment, :answers_attachment, 
                                  questions_attachment: :blob, answers_attachment: :blob)
             .index_by(&:week)
    @homeworks_by_week_and_level = @course.homeworks.index_by { |h| [h.week, h.level] }
    @homeworks_grouped_by_level = @course&.homeworks&.group_by(&:short_level)

    else
      {}
    end

  end

  def new
    @homework = @course.homeworks.new
  end

  def create
    @homework = @course.homeworks.find_or_initialize_by(week: homework_params[:week], level: homework_params[:level])
    authorize @homework
    @homework.assign_attributes(homework_params)
  
    if @homework.save
      redirect_to homeworks_path(course_id: @course.id), notice: 'Homework saved.'
    else
      redirect_to homeworks_path(course_id: @course.id), alert: 'Failed to save homework.'
    end
  end
  

  def destroy
    @course = @homework.course
    authorize @homework
    @homework.destroy
    redirect_to homeworks_path(course_id: @course.id), notice: 'Homework deleted.'
  end

  private

  def set_course
    @course = Course.find_by(id: params[:course_id])
  end

  def set_courses
    @courses = policy_scope(Course)
  end

  def set_homework
    @homework = Homework.find(params[:id])
  end

  def homework_params
    params.require(:homework).permit(:week, :questions, :answers, :level)
  end
  
  def week_range_start(org)
    plan = Plan.find_by(course_id: course_id, organisation_id: org.id)
    return nil unless plan

    plan.start + (week - 1).weeks
  end
end
