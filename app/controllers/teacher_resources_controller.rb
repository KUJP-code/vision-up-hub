# frozen_string_literal: true

class TeacherResourcesController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  def index
    @lesson_category = set_lesson_category
    @category_resources = policy_scope(CategoryResource)
                          .with_attached_resource
                          .send(@lesson_category)
  end

  private

  def set_lesson_category
    allowed_categories = CategoryResource.lesson_categories.keys
    unless Flipper.enabled?(:afterschool_extras, current_user)
      allowed_categories -= CategoryResource::AFTERSCHOOL_EXTRAS
    end
    category = params[:category]
    unless allowed_categories.include?(category)
      redirect_to teacher_resources_url(category: allowed_categories.first),
                  alert: t('not_authorized')
    end

    category
  end
end
