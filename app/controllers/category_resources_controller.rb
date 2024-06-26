# frozen_string_literal: true

class CategoryResourcesController < ApplicationController
  before_action :set_category_resource, only: %i[edit update destroy]
  after_action :verify_authorized, only: %i[create edit destroy update]
  after_action :verify_policy_scoped, only: :index

  def index
    @category_resources = policy_scope(CategoryResource)
                          .with_attached_resource
                          .includes(:courses)
                          .order(
                            lesson_category: :asc,
                            level: :asc,
                            resource_category: :asc,
                            'active_storage_blobs.filename': :asc
                          )
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

  def category_resource_params
    params.require(:category_resource).permit(
      :lesson_category, :level, :resource_category, :resource
    )
  end

  def set_category_resource
    @category_resource = authorize CategoryResource.find(params[:id])
  end
end
