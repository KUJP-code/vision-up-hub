# frozen_string_literal: true

class TeacherResourcesController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  ALLOWED_CATEGORIES = CategoryResource.lesson_categories.keys

  def index
    @lesson_category = params[:category] if ALLOWED_CATEGORIES.include?(params[:category])
    @category_resources = policy_scope(CategoryResource)
                          .with_attached_resource
                          .send(@lesson_category)
                          .group_by(&:resource_category)
  end
end
