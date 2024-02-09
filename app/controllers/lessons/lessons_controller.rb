# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[destroy edit show update]
  before_action :set_courses, only: %i[new edit]
  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]
  after_action :generate_guide, only: %i[create update]

  def index
    @lessons = policy_scope(Lesson.all)
  end

  def show
    @courses = @lesson.courses
    @writers = User.where(type: %w[Admin Writer]).pluck(:name, :id) if current_user.is?('Admin')
  end

  def new
    type = params[:type] if Lesson::TYPES.include?(params[:type])
    @lesson = authorize type.constantize.new
  end

  def edit; end

  def create
    @lesson.creator_id = current_user.id
    @lesson.assigned_editor_id = current_user.id
  end

  def update
    redirect_to root_url,
                alert: 'This route should be overwritten when inherited'
  end

  def destroy
    if @lesson.destroy
      redirect_to lessons_path,
                  notice: 'Lesson was successfully destroyed.'
    else
      redirect_to lessons_path,
                  alert: "Lesson could not be destroyed. Check it's not still in use"
    end
  end

  private

  def lesson_params
    return [{ curriculum_approval: %i[id name time] }] unless current_user.is?('Admin')

    [:assigned_editor_id, :goal, :level, :title, :type,
     { course_lessons_attributes: %i[id _destroy course_id day lesson_id week],
       admin_approval: %i[id name time], curriculum_approval: %i[id name time] }]
  end

  def set_courses
    @courses = Course.pluck(:title, :id)
  end

  def set_lesson
    @lesson = authorize Lesson.find(params[:id])
  end

  def generate_guide
    return if @lesson.new_record?

    @lesson.attach_guide
  end
end
