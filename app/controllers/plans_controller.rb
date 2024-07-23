# frozen_string_literal: true

class PlansController < ApplicationController
  before_action :set_plan, only: %i[show edit update destroy]
  before_action :set_form_data, only: %i[new edit]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @plans = policy_scope(Plan).includes(:course, :organisation)
                               .order(created_at: :desc)
  end

  def show; end

  def new
    @plan = authorize Plan.new(organisation_id: params[:organisation_id])
  end

  def edit; end

  def create
    @plan = authorize Plan.new(plan_params)

    if @plan.save
      redirect_to @plan,
                  notice: t('create_success')
    else
      set_form_data
      render :new,
             status: :unprocessable_entity,
             alert: t('create_failure')
    end
  end

  def update
    if @plan.update(plan_params)
      redirect_to @plan,
                  notice: t('update_success')
    else
      set_form_data
      render :edit,
             status: :unprocessable_entity,
             alert: t('update_failure')
    end
  end

  def destroy
    if @plan.destroy
      redirect_to plans_url,
                  notice: t('destroy_success')
    else
      redirect_to plans_url,
                  status: :unprocessable_entity,
                  alert: t('destroy_failure')
    end
  end

  private

  def plan_params
    params.require(:plan).permit(
      :course_id, :finish_date, :name, :organisation_id, :start, :student_limit, :total_cost
    )
  end

  def set_form_data
    @courses = Course.pluck(:title, :id)
    @organisations = Organisation.pluck(:name, :id)
  end

  def set_plan
    @plan = authorize Plan.find(params[:id])
  end
end
