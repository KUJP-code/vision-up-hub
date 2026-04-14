# frozen_string_literal: true

class CategoryResourcesController < ApplicationController
  before_action :set_category_resource, only: %i[edit update destroy]
  before_action :set_form_data, only: %i[new create edit update]
  before_action :set_batch_copy_courses, only: %i[batch_copy batch_copy_preview batch_copy_create]
  after_action :verify_authorized, only: %i[create edit destroy update batch_copy batch_copy_preview batch_copy_create]
  after_action :verify_policy_scoped, only: :index

  def index
    @category_resources = category_resources_scope
  end

  def batch_copy
    authorize CategoryResource
    @batch_copy = default_batch_copy
  end

  def batch_copy_preview
    authorize CategoryResource
    @batch_copy = batch_copy_params.to_h.symbolize_keys
    return render_batch_copy_with_alert('Please choose both a source course and a destination course.') unless batch_copy_courses_present?
    return render_batch_copy_with_alert('Please choose a lesson category to copy.') if batch_copy_params[:lesson_category].blank?
    return render_batch_copy_with_alert('Source and destination courses must be different.') if same_batch_copy_course?

    load_batch_copy_summary
    render :batch_copy
  end

  def batch_copy_create
    authorize CategoryResource
    @batch_copy = batch_copy_params.to_h.symbolize_keys
    return render_batch_copy_with_alert('Please choose both a source course and a destination course.') unless batch_copy_courses_present?
    return render_batch_copy_with_alert('Please choose a lesson category to copy.') if batch_copy_params[:lesson_category].blank?
    return render_batch_copy_with_alert('Source and destination courses must be different.') if same_batch_copy_course?

    load_batch_copy_summary

    copied_count = 0

    CourseResource.transaction do
      @copyable_resources.find_each do |category_resource|
        CourseResource.create!(course: @destination_course, category_resource:)
        copied_count += 1
      end
    end

    redirect_to category_resources_path,
                notice: "Copied #{copied_count} #{@lesson_category_label} resources to #{@destination_course.title}. Skipped #{@already_attached_resources.size} that were already attached."
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

  def batch_copy_params
    params.fetch(:batch_copy, {}).permit(:source_course_id, :destination_course_id, :lesson_category)
  end

  def set_batch_copy_courses
    @courses = policy_scope(Course).order(:title)
  end

  def default_batch_copy
    { source_course_id: nil, destination_course_id: nil, lesson_category: nil }
  end

  def batch_copy_courses_present?
    batch_copy_params[:source_course_id].present? && batch_copy_params[:destination_course_id].present?
  end

  def same_batch_copy_course?
    batch_copy_params[:source_course_id] == batch_copy_params[:destination_course_id]
  end

  def render_batch_copy_with_alert(message)
    @batch_copy_summary = nil
    flash.now[:alert] = message
    render :batch_copy, status: :unprocessable_entity
  end

  def load_batch_copy_summary
    @source_course = @courses.find(batch_copy_params[:source_course_id])
    @destination_course = @courses.find(batch_copy_params[:destination_course_id])
    @lesson_category = batch_copy_params[:lesson_category]
    @lesson_category_label = I18n.t("category_resources.#{@lesson_category}")

    source_resources = @source_course.category_resources.where(lesson_category: @lesson_category).distinct
    destination_resource_ids = @destination_course.category_resources.distinct.pluck(:id)

    @already_attached_resources = source_resources.where(id: destination_resource_ids)
    @copyable_resources = source_resources.where.not(id: destination_resource_ids)

    @batch_copy_summary = {
      total_source_resources: source_resources.count,
      already_attached_count: @already_attached_resources.size,
      copyable_count: @copyable_resources.count
    }
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
