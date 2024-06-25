# frozen_string_literal: true

class TeacherResourcesController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  ALLOWED_CATEGORIES = CategoryResource.lesson_categories.keys

  def index
    @category_resources = policy_scope(CategoryResource)
                          .with_attached_resource
                          .send(@lesson_category)
                          .group_by(&:resource_category)
  end

  private

  def set_lesson_category
    category = params[:category]
    return CategoryResource.lesson_categories.keys.first unless ALLOWED_CATEGORIES.include?(category)

    @lesson_category = category
  end
end
