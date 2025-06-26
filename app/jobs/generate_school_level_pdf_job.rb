class GenerateSchoolLevelPdfJob < ApplicationJob
  queue_as :pdf_generation

  def perform(batch_id)
    batch = ReportCardBatch.find(batch_id)
    GenerateSchoolLevelPdfService.new(batch).call
  ensure
    NotifyUserJob.perform_later(
      user_id: batch.user_id,
      text:    "Report PDF for #{batch.level.titleize} is #{batch.status}.",
      link:    (Rails.application.routes.url_helpers.rails_blob_url(
                  batch.file, disposition: 'attachment', only_path: false
                ) if batch.complete_status?)
    )
  end
end