# frozen_string_literal: true

class TutorialsController < ApplicationController
  before_action :set_tutorial, only: %i[show edit update destroy]
  after_action :verify_authorized, except: :index

  def index
    visible_resources = policy_scope(TutorialCategory).includes(:tutorial_section, cover_image_attachment: :blob)
    visible_resources = resources_for_spy(visible_resources)
    @section_entries = section_entries(visible_resources)
    @selected_section = selected_section(@section_entries)
    @show_section_picker = @section_entries.many? && @selected_section.nil?
    @categories = @show_section_picker ? TutorialCategory.none : resources_in(@selected_section, visible_resources)
  end

  def show
    @item = @tutorial.items.fetch(params[:item].to_i, {}) if params.key?(:item)
  end

  def new
    @tutorial = authorize TutorialCategory.new(tutorial_section_id: params[:tutorial_section_id])
  end

  def edit; end

  def create
    @tutorial = authorize TutorialCategory.new(tutorial_params.merge(position: next_position))
    if @tutorial.save
      redirect_to tutorials_path(section: section_param), notice: 'Resource was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    attributes = tutorial_params
    retain_existing_files(attributes)
    assign_new_position(attributes)
    if @tutorial.update(attributes)
      redirect_to tutorials_path(section: section_param), notice: 'Resource was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    section = section_param
    @tutorial.destroy
    redirect_to tutorials_path(section:), notice: 'Resource was successfully deleted.'
  end

  def reorder
    authorize TutorialCategory, :update?
    section_id = params[:tutorial_section_id].presence
    reorder_records(TutorialCategory.where(tutorial_section_id: section_id), params[:tutorial_ids])
    head :no_content
  end

  private

  def tutorial_params
    params.require(:tutorial_category).permit(
      :title, :cover_image, :tutorial_section_id,
      files: [], remove_file_ids: [], items_attributes: %i[kind title url body _destroy],
      organisation_tutorial_categories_attributes: %i[id organisation_id _destroy]
    )
  end

  def set_tutorial
    @tutorial = authorize TutorialCategory.find(params[:id])
  end

  def resources_for_spy(scope)
    return scope unless current_user.is?('Admin') && params[:organisation_id].present?

    scope.joins(:organisation_tutorial_categories)
         .where(organisation_tutorial_categories: { organisation_id: params[:organisation_id] })
  end

  def section_entries(resources)
    entries = visible_sections(resources).map { |section| [section.id.to_s, section] }
    entries << ['others', nil] if resources.exists?(tutorial_section_id: nil)
    entries
  end

  def visible_sections(resources)
    return TutorialSection.all if current_user.is?('Admin', 'Sales') && params[:organisation_id].blank?

    TutorialSection.where(id: resources.where.not(tutorial_section_id: nil).select(:tutorial_section_id))
  end

  def selected_section(entries)
    return entries.first if entries.one?
    return if params[:section].blank?

    entries.find { |key, _section| key == params[:section].to_s }
  end

  def resources_in(section_entry, resources)
    return resources.reorder(:position, :title) unless section_entry

    key, section = section_entry
    scope = key == 'others' ? resources.where(tutorial_section_id: nil) : resources.where(tutorial_section: section)
    scope.reorder(:position, :title)
  end

  def section_param
    @tutorial.tutorial_section_id || 'others'
  end

  def next_position
    section_id = tutorial_params[:tutorial_section_id].presence
    (TutorialCategory.where(tutorial_section_id: section_id).maximum(:position) || -1) + 1
  end

  def retain_existing_files(attributes)
    attributes[:files] = @tutorial.files.blobs + attributes[:files] if attributes[:files].present?
  end

  def assign_new_position(attributes)
    new_section_id = attributes[:tutorial_section_id].presence&.to_i
    return if new_section_id == @tutorial.tutorial_section_id

    attributes[:position] = (TutorialCategory.where(tutorial_section_id: new_section_id).maximum(:position) || -1) + 1
  end

  def reorder_records(scope, ordered_ids)
    records = scope.where(id: Array(ordered_ids)).index_by { |record| record.id.to_s }
    TutorialCategory.transaction do
      Array(ordered_ids).each_with_index { |id, position| records[id.to_s]&.update!(position:) }
    end
  end
end
