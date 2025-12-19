# frozen_string_literal: true

class GeneratePearsonReportPdfJob < ApplicationJob
  queue_as :pdf_generation

  def perform(batch_id)
    batch = PearsonReportBatch.find(batch_id)
    PearsonReportBatchService.new(batch).call
  ensure
    host = Rails.application.routes.default_url_options[:host] ||
           ENV.fetch('APP_HOST', 'http://localhost:3000')

    NotifyUserJob.perform_later(
      user_id: batch.user_id,
      text: "Pearson report PDF (#{batch.level.titleize}) is #{batch.status}.",
      link: Rails.application.routes.url_helpers.report_card_batches_url(
        school_id: batch.school_id,
        view: 'pearson',
        host:
      )
    )
  end
end
