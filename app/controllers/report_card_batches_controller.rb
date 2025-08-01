class ReportCardBatchesController < ApplicationController
  before_action :set_batch, only: :regenerate
  before_action :set_context
  after_action  :verify_authorized

  def index
    authorize ReportCardBatch

    return redirect_to root_path, alert: t('no_school') unless @school

    @batches = policy_scope(ReportCardBatch)
               .where(school_id: @school.id)
               .with_attached_file
               .order(:level)
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
        school_id: params[:school_id],
        level:     params[:level]
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
end
