# frozen_string_literal: true

class SchoolClassesController < ApplicationController
  before_action :set_school_class, only: %i[edit show update destroy]
  before_action :set_schools, only: %i[edit index new update]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @school_classes = policy_scope(SchoolClass)
  end

  def show
    @students = @school_class.students.includes(:classes, :school)
    @possible_students = policy_scope(Student).where
                                              .not(id: @students.ids)
                                              .pluck(:name, :id)
  end

  def new
    @school_class = authorize SchoolClass.new
  end

  def edit; end

  def create
    @school_class = authorize SchoolClass.new(school_class_params)

    if @school_class.save
      redirect_to school_class_url(@school_class),
                  notice: t('create_success')
    else
      set_schools
      render :new, status: :unprocessable_entity,
                   alert: t('create_failure')
    end
  end

  def update
    if @school_class.update(school_class_params)
      redirect_to school_class_url(@school_class),
                  notice: t('update_success')
    else
      set_schools
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

  def set_schools
    @schools = policy_scope(School).pluck(:name, :id)
  end
end
