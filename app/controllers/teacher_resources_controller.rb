# frozen_string_literal: true

class TeacherResourcesController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  ALLOWED_CATEGORIES = CategoryResource.lesson_categories.keys

  def index
    @lesson_cattegory = set_lesson_category
    @category_resources = policy_scope(CategoryResource)
                          .with_attached_resource
                          .send(@lesson_category)
  end

  private

  def set_lesson_category
    category = params[:category]
    return ALLOWED_CATEGORIES.first unless ALLOWED_CATEGORIES.include?(category)

    category
  end
end
