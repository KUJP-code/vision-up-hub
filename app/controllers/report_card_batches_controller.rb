# frozen_string_literal: true

class ReportCardBatchesController < ApplicationController
  before_action :set_context
  before_action :set_view
  before_action :set_batch, only: :regenerate
  after_action  :verify_authorized

  def index
    authorize policy_record

    return redirect_to root_path, alert: t('no_school') unless @school

    load_batches
  end

  def create
    batch = find_or_initialize_batch
    authorize batch

    if batch.generating_status?
      redirect_back fallback_location: fallback_path,
                    alert: t('generation_in_progress')
    else
      batch.update!(user: current_user, status: :pending)
      enqueue_job(batch)
      redirect_back fallback_location: fallback_path,
                    notice: t('generation_started')
    end
  end

  def regenerate
    authorize @batch
    @batch.update!(status: :pending, user: current_user)
    enqueue_job(@batch)
    redirect_back fallback_location: fallback_path,
                  notice: t('generation_started')
  end

  private

  def set_batch
    @batch = batch_class.find(params[:id])
  end

  def find_or_initialize_batch
    level = params[:level]
    level ||= 'school' if pearson_view?

    batch_class.find_or_initialize_by(
      school_id: params[:school_id],
      level:
    )
  end

  def set_context
    if current_user.is?('OrgAdmin')
      @org = current_user.organisation
    elsif params[:org_id]
      @org = authorize Organisation.find(params[:org_id]), :show?
    end

    @schools = policy_scope(School)
    @schools = @schools.where(organisation_id: @org.id) if @org.present?

    @school = @schools.find_by(id: params[:school_id]) || @schools.first
    authorize @school, :show?
  end

  def set_view
    @current_view = params[:view] == 'pearson' ? 'pearson' : 'school'
  end

  def pearson_view?
    @current_view == 'pearson'
  end

  def batch_class
    pearson_view? ? PearsonReportBatch : ReportCardBatch
  end

  def policy_record
    pearson_view? ? PearsonReportBatch : ReportCardBatch
  end

  def enqueue_job(batch)
    if pearson_view?
      GeneratePearsonReportPdfJob.perform_later(batch.id)
    else
      GenerateSchoolLevelPdfJob.perform_later(batch.id)
    end
  end

  def fallback_path
    report_card_batches_path(view: @current_view, school_id: params[:school_id])
  end

  def load_batches
    @pearson_batches = policy_scope(PearsonReportBatch)
                       .where(school_id: @school.id)
                       .with_attached_file
                       .to_a

    @batches = policy_scope(ReportCardBatch)
               .where(school_id: @school.id)
               .with_attached_file
               .order(:level)
  end
end
