# frozen_string_literal: true

class TeacherResourcesController < ApplicationController
  helper_method :resource_group_icon_path, :resource_group_tab_style
  after_action :verify_policy_scoped, only: :index

  def index
    base_scope = policy_scope(CategoryResource)
                 .with_attached_resource
                 .joins(:resource_attachment)

    @requested_card = params[:card].presence
    @allowed_categories = allowed_categories_for(current_user, base_scope, level: params[:level])
    @lesson_category    = set_lesson_category
    return if performed? # in case we redirected

    @category_resources = base_scope.public_send(@lesson_category)
    @grouping = @lesson_category == 'brush_up' ? :level : :resource_category
    @grouped_resources = @category_resources.group_by(&@grouping)
    @group_options = ordered_groups(@grouped_resources.keys)
    @active_group = set_active_group
    @active_resources = @grouped_resources.fetch(@active_group, [])
                                      .select { |resource| resource.resource.attached? }
                                      .sort_by { |resource| resource.resource.blob.filename.to_s }
    @resource_title = resource_title
  end

  private

  # All Flipper + "only categories with records" logic
  def allowed_categories_for(user, base_scope, level:)
    categories = CategoryResource.lesson_categories.keys

    categories -= CategoryResource::AFTERSCHOOL_EXTRAS unless Flipper.enabled?(:afterschool_extras, user)
    categories << 'snack' if level == 'keep_up'

    unless Flipper.enabled?(:keep_up, user) ||
           Flipper.enabled?(:specialist, user)
      categories -= %w[evening_class ku_book_activity ku_lesson_review]
    end

    # 🔑 Only keep categories that actually have records in the scoped data
    categories.select { |cat| base_scope.public_send(cat).exists? }
  end

  def set_lesson_category
    category = requested_category
    category = @allowed_categories.first if category.blank?

    unless @allowed_categories.include?(category)
      redirect_to teacher_resources_url(category: @allowed_categories.first),
                  alert: t('not_authorized')
      return
    end

    category
  end

  def requested_category
    { 'book_activity' => 'ku_book_activity',
      'lesson_review' => 'ku_lesson_review' }.fetch(params[:category].to_s, params[:category].to_s)
  end

  def ordered_groups(groups)
    order = if @grouping == :level
              CategoryResource.levels.keys
            else
              CategoryResource.resource_categories.keys
            end

    order.select { |group| groups.include?(group) }
  end

  def set_active_group
    group = params[:group].presence || default_group_for(@requested_card)
    return @group_options.first if group.blank?

    @group_options.include?(group) ? group : @group_options.first
  end

  def default_group_for(card)
    { 'book_activity' => 'worksheets' }[card]
  end

  def resource_title
    key = @requested_card || @lesson_category
    I18n.t("category_resources.#{key}", default: I18n.t("teacher_resources.index.#{key}", default: key.to_s.humanize))
  end

  def resource_group_icon_path(group)
    if @grouping == :level
      "levels/#{group}.svg"
    else
      "resource_groups/#{group}.svg"
    end
  end

  def resource_group_tab_style(index)
    count = @group_options.size
    top_positions = case count
                    when 1
                      [40]
                    when 2
                      [15, 40]
                    when 3
                      [15, 40, 65]
                    else
                      Array.new(count) { |i| 15 + ((50.0 / (count - 1)) * i) }
                    end

    "top: #{top_positions.fetch(index).round(2)}%;"
  end
end
