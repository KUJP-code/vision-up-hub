# frozen_string_literal: true

class TeacherToolsController < ApplicationController
  before_action :set_form_data, only: %i[index new create edit update batch_copy batch_copy_preview batch_copy_create]
  before_action :set_teacher_tool, only: %i[edit update destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    @teacher_tools = policy_scope(TeacherTool)
    @orgs = policy_scope(Organisation).order(:name)
    @organisation = selected_organisation
    @teacher_tools = @teacher_tools.where(organisation: @organisation).order(:position, :id)
    authorize TeacherTool
  end

  def batch_copy
    authorize TeacherTool
    @batch_copy = default_batch_copy
  end

  def batch_copy_preview
    authorize TeacherTool
    @batch_copy = batch_copy_params.to_h.symbolize_keys
    return render_batch_copy_with_alert('Please choose both a source organisation and a destination organisation.') unless batch_copy_orgs_present?
    return render_batch_copy_with_alert('Source and destination organisations must be different.') if same_batch_copy_org?

    load_batch_copy_summary
    render :batch_copy
  end

  def batch_copy_create
    authorize TeacherTool
    @batch_copy = batch_copy_params.to_h.symbolize_keys
    return render_batch_copy_with_alert('Please choose both a source organisation and a destination organisation.') unless batch_copy_orgs_present?
    return render_batch_copy_with_alert('Source and destination organisations must be different.') if same_batch_copy_org?

    load_batch_copy_summary

    copied_count = 0

    TeacherTool.transaction do
      @copyable_tools.each do |tool|
        copied_tool = @destination_org.teacher_tools.new(
          title: tool.title,
          description: tool.description,
          kind: tool.kind,
          url: tool.url,
          embed_url: tool.embed_url,
          duration_label: tool.duration_label,
          position: next_destination_position
        )
        copied_tool.cover_image.attach(tool.cover_image.blob) if tool.cover_image.attached?
        copied_tool.save!
        copied_count += 1
      end
    end

    redirect_to teacher_tools_path(organisation_id: @destination_org.id),
                notice: "Copied #{copied_count} teacher tools to #{@destination_org.name}. Skipped #{@already_attached_tools.size} duplicates."
  end

  def new
    @organisation = selected_organisation
    @teacher_tool = authorize @organisation.teacher_tools.new(active: true, position: next_position)
  end

  def create
    @organisation = selected_organisation
    @teacher_tool = authorize @organisation.teacher_tools.new(teacher_tool_params)

    if @teacher_tool.save
      redirect_to teacher_tools_path(organisation_id: @organisation.id),
                  notice: 'Teacher tool was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @teacher_tool.update(teacher_tool_params)
      redirect_to teacher_tools_path(organisation_id: @teacher_tool.organisation_id),
                  notice: 'Teacher tool was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @teacher_tool.destroy
      redirect_to teacher_tools_path(organisation_id: @teacher_tool.organisation_id),
                  notice: 'Teacher tool was successfully deleted.'
    else
      redirect_to teacher_tools_path(organisation_id: @teacher_tool.organisation_id),
                  alert: @teacher_tool.errors.full_messages.to_sentence.presence || 'Teacher tool could not be deleted.'
    end
  end

  private

  def set_form_data
    @organisations = Organisation.order(:name)
  end

  def set_teacher_tool
    @teacher_tool = authorize TeacherTool.find(params[:id])
    @organisation = @teacher_tool.organisation
  end

  def teacher_tool_params
    params.require(:teacher_tool).permit(
      :title,
      :description,
      :kind,
      :cover_image,
      :video_path,
      :url,
      :duration_label,
      :position,
      :active
    )
  end

  def selected_organisation(default_id = nil)
    organisations = @orgs || @organisations || policy_scope(Organisation).order(:name)
    id = params[:organisation_id].presence || default_id || organisations.first&.id
    organisations.find { |org| org.id == id.to_i } || organisations.first
  end

  def next_position
    (@organisation.teacher_tools.maximum(:position) || -1) + 1
  end

  def batch_copy_params
    params.fetch(:batch_copy, {}).permit(:source_organisation_id, :destination_organisation_id)
  end

  def default_batch_copy
    { source_organisation_id: nil, destination_organisation_id: nil }
  end

  def batch_copy_orgs_present?
    batch_copy_params[:source_organisation_id].present? && batch_copy_params[:destination_organisation_id].present?
  end

  def same_batch_copy_org?
    batch_copy_params[:source_organisation_id] == batch_copy_params[:destination_organisation_id]
  end

  def render_batch_copy_with_alert(message)
    @batch_copy_summary = nil
    flash.now[:alert] = message
    render :batch_copy, status: :unprocessable_entity
  end

  def load_batch_copy_summary
    @source_org = @organisations.find(batch_copy_params[:source_organisation_id])
    @destination_org = @organisations.find(batch_copy_params[:destination_organisation_id])

    source_tools = @source_org.teacher_tools.order(:position, :id)
    destination_keys = @destination_org.teacher_tools.pluck(:title, :kind)

    @already_attached_tools = source_tools.select { |tool| destination_keys.include?([tool.title, tool.kind]) }
    @copyable_tools = source_tools.reject { |tool| destination_keys.include?([tool.title, tool.kind]) }

    @batch_copy_summary = {
      total_source_tools: source_tools.count,
      already_attached_count: @already_attached_tools.size,
      copyable_count: @copyable_tools.count
    }
  end

  def next_destination_position
    (@destination_org.teacher_tools.maximum(:position) || -1) + 1
  end
end
