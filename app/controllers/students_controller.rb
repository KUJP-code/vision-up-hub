# frozen_string_literal: true

class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
  before_action :set_schools, only: %i[edit new show]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @students = policy_scope(Student).includes(:school, :classes)
  end

  def show; end

  def new
    @student = authorize Student.new
    build_classes
  end

  def edit
    build_classes
  end

  def create
    @student = Student.new(student_params)

    if @student.save
      redirect_to @student, notice: t('create_success')
    else
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    if @student.update(student_params)
      redirect_to @student, notice: t('update_success')
    else
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  def destroy
    if @student.destroy
      redirect_to students_path,
                  notice: t('destroy_success')
    else
      redirect_to students_path,
                  alert: t('destroy_failure')
    end
  end

  private

  def student_params
    params.require(:student).permit(
      :comments, :level, :name, :school_id, :student_id,
      student_classes_attributes: %i[id class_id _destroy]
    )
  end

  def set_student
    @student = authorize Student.find(params[:id])
  end

  def set_schools
    @schools = policy_scope(School).pluck(:name, :id)
  end

  def build_classes
    @student.student_classes.build(class_id: params[:class_id]) if params[:class_id]
  end
end
