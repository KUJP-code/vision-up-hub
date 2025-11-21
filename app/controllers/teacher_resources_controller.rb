# frozen_string_literal: true

class TeacherResourcesController < ApplicationController
  after_action :verify_policy_scoped, only: :index

  def index
    base_scope = policy_scope(CategoryResource).with_attached_resource

    @allowed_categories = allowed_categories_for(current_user, base_scope)
    @lesson_category    = set_lesson_category
    return if performed? # in case we redirected

    @category_resources = base_scope.public_send(@lesson_category)
  end

  private

  # All Flipper + "only categories with records" logic
  def allowed_categories_for(user, base_scope)
    categories = CategoryResource.lesson_categories.keys

    categories -= CategoryResource::AFTERSCHOOL_EXTRAS unless Flipper.enabled?(:afterschool_extras, user)

    unless Flipper.enabled?(:keep_up, user) ||
           Flipper.enabled?(:specialist, user)
      categories -= %w[evening_class]
    end

    # 🔑 Only keep categories that actually have records in the scoped data
    categories.select { |cat| base_scope.public_send(cat).exists? }
  end

  def set_lesson_category
    category = params[:category].to_s
    category = @allowed_categories.first if category.blank?

    unless @allowed_categories.include?(category)
      redirect_to teacher_resources_url(category: @allowed_categories.first),
                  alert: t('not_authorized')
      return
    end

    category
  end
end
