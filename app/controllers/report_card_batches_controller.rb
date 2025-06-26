class ReportCardBatchesController < ApplicationController
  before_action :set_batch, only: :regenerate
  after_action  :verify_authorized

  def index
    @batches = policy_scope(ReportCardBatch).order(:level)
    authorize @batches
  end

  def create
    batch = find_or_initialize_batch
    authorize batch

    if batch.generating_status?
      redirect_back fallback_location: report_card_batches_path,
                    alert: t('generation_in_progress')
    else
      batch.update!(user: current_user, status: :pending)
      GenerateSchoolLevelPdfJob.perform_later(batch.id)
      redirect_back fallback_location: report_card_batches_path,
                    notice: t('generation_started')
    end
  end

  def regenerate
    authorize @batch
    @batch.update!(status: :pending, user: current_user)
    GenerateSchoolLevelPdfJob.perform_later(@batch.id)
    redirect_back fallback_location: report_card_batches_path,
                  notice: t('generation_started')
  end

  private

  def set_batch
    @batch = ReportCardBatch.find(params[:id])
  end

  def find_or_initialize_batch
    ReportCardBatch.find_or_initialize_by(
      school_id: current_user.school_ids,
      level:     params[:level]
    )
  end
end
