# frozen_string_literal: true

class SchoolClassesController < ApplicationController
  before_action :set_school_class, only: %i[edit show update destroy]
  before_action :set_form_data, only: %i[edit index new update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @school_classes = policy_scope(SchoolClass)
    @school_classes = @school_classes.includes(:school) if current_user.is?('Admin', 'OrgAdmin')
  end

  def show
    @students = @school_class.students.includes(:school)
    @possible_students = policy_scope(Student).where
                                              .not(id: @students.ids)
                                              .pluck(:name, :id)
    @teachers = @school_class.teachers.pluck(:name)
  end

  def new
    @school_class = authorize SchoolClass.new(school_id: params[:school_id])
  end

  def edit; end

  def create
    @school_class = authorize SchoolClass.new(school_class_params)

    if @school_class.save
      redirect_to school_class_url(@school_class),
                  notice: t('create_success')
    else
      set_form_data
      render :new, status: :unprocessable_entity,
                   alert: t('create_failure')
    end
  end

  def update
    if @school_class.update(school_class_params)
      redirect_to school_class_url(@school_class),
                  notice: t('update_success')
    else
      set_form_data
      render :edit, status: :unprocessable_entity,
                    alert: t('update_failure')
    end
  end

  def destroy
    if @school_class.destroy
      redirect_to school_classes_url,
                  notice: t('destroy_success')
    else
      redirect_to school_classes_url,
                  alert: t('destroy_failure')
    end
  end

  private

  def school_class_params
    params.require(:school_class).permit(
      :name, :school_id, student_classes_attributes: %i[id student_id]
    )
  end

  def set_school_class
    @school_class = authorize(SchoolClass.find(params[:id]))
  end

  def set_form_data
    @schools = policy_scope(School).pluck(:name, :id)
    @teachers = policy_scope(User).where(type: 'Teacher').pluck(:name, :id)
  end
end
