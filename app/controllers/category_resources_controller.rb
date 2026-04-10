# frozen_string_literal: true

class CategoryResourcesController < ApplicationController
  before_action :set_category_resource, only: %i[edit update destroy]
  before_action :set_form_data, only: %i[new create edit update]
  after_action :verify_authorized, only: %i[create edit destroy update]
  after_action :verify_policy_scoped, only: :index

  def index
    @category_resources = category_resources_scope
  end

  def new
    @category_resource = authorize CategoryResource.new
  end

  def edit
    @phonics_resources = @category_resource.phonics_resources.includes(:phonics_class)
  end

  def create
    @category_resource = authorize CategoryResource.new(category_resource_params)
    if @category_resource.save
      redirect_to category_resources_path,
                  notice: 'Category resource successfully created'
    else
      render :new, status: :unprocessable_entity,
                   alert: 'Category resource could not be created'
    end
  end

  def update
    if @category_resource.update(category_resource_params)
      redirect_to category_resources_path,
                  notice: 'Category resource successfully updated'
    else
      @phonics_resources = @category_resource.phonics_resources.includes(:phonics_class)
      render :edit, status: :unprocessable_entity,
                    alert: 'Category resource could not be updated'
    end
  end

  def destroy
    if @category_resource.destroy
      redirect_to category_resources_path,
                  notice: 'Category resource successfully destroyed'
    else
      redirect_to category_resources_path,
                  status: :unprocessable_entity,
                  alert: 'Category resource could not be destroyed'
    end
  end

  private

  def category_resources_scope
    resources = policy_scope(CategoryResource)
                .left_joins(resource_attachment: :blob)
                .includes(:courses, resource_attachment: :blob)
    resources = resources.where(lesson_category: search_params[:lesson_category]) if search_params[:lesson_category].present?
    resources = resources.where(level: search_params[:level]) if search_params[:level].present?
    resources = resources.where(resource_category: search_params[:resource_category]) if search_params[:resource_category].present?
    resources = resources.where('active_storage_blobs.filename ILIKE ?', "%#{search_params[:filename]}%") if search_params[:filename].present?
    if search_params[:used_by].present?
      resources = resources.where(
        id: CategoryResource.joins(:courses)
                            .where('courses.title ILIKE ?', "%#{search_params[:used_by]}%")
                            .select(:id)
      )
    end

    resources.order(
      lesson_category: :asc,
      level: :asc,
      resource_category: :asc,
      'active_storage_blobs.filename': :asc
    )
  end

  def search_params
    params.fetch(:search, {}).permit(
      :filename,
      :lesson_category,
      :level,
      :resource_category,
      :used_by
    ).compact_blank
  end

  def category_resource_params
    params.require(:category_resource).permit(
      :lesson_category, :course_id, :is_answers, :level, :resource_category, :resource,
      course_resources_attributes: %i[id course_id _destroy]
    )
  end

  def set_category_resource
    @category_resource = authorize CategoryResource.find(params[:id])
  end

  def set_form_data
    @courses = Course.pluck(:title, :id)
  end
end
