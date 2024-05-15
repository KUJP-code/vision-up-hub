# frozen_string_literal: true

class SchoolsController < ApplicationController
  before_action :set_school, only: %i[show edit update destroy]
  before_action :set_managers, only: %i[edit new]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @schools = policy_scope(School).includes(:organisation)
  end

  def show
    @managers = @school.school_managers.pluck(:name).to_sentence
    @classes = @school.classes.includes(:teachers)
  end

  def new
    @school = authorize School.new(organisation_id: params[:organisation_id])
  end

  def edit; end

  def create
    @school = authorize School.new(
      school_params.merge(organisation_id: params[:organisation_id])
    )

    if @school.save
      redirect_to organisation_school_url(@school.organisation, @school),
                  notice: t('create_success')
    else
      set_managers
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    if @school.update(school_params)
      redirect_to organisation_school_url(@school.organisation, @school),
                  notice: t('update_success')
    else
      set_managers
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  def destroy
    if @school.destroy
      redirect_to organisation_schools_url(@school.organisation),
                  notice: t('destroy_success')
    else
      redirect_to organisation_school_url(@school.organisation, @school),
                  alert: t('destroy_failure')
    end
  end

  private

  def school_params
    params.require(:school).permit(
      :name,
      managements_attributes: %i[id school_id school_manager_id _destroy]
    )
  end

  def set_school
    @school = authorize School.find(params[:id])
  end

  def set_managers
    @managers = policy_scope(User)
                .where(type: 'SchoolManager')
                .pluck(:name, :id)
  end
end
