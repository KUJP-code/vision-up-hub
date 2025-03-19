class HomeworksController < ApplicationController
  before_action :set_course
  before_action :set_homework, only: %i[show destroy]
  after_action :verify_policy_scoped, only: %i[index]
  after_action :verify_authorized, except: %i[index]

  def index
    @homeworks = @course.homeworks
  end

  def new
    @homework = @course.homeworks.new
  end

  def create
    @homework = @course.homeworks.new(homework_params)

    if @homework.save
      redirect_to course_homeworks_path(@course), notice: 'Homework uploaded.'
    else
      render :new
    end
  end

  def destroy
    @homework.destroy
    redirect_to course_homeworks_path(@course), notice: 'Homework deleted.'
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def homework_params
    params.require(:homework).permit(:week, :questions, :answers)
  end
end
