# frozen_string_literal: true

require 'grover'

class ReportCardBatchService
  RECENT_WINDOW = 3.months

  def initialize(batch)
    @batch = batch
    @cutoff = RECENT_WINDOW.ago
  end

  def call
    batch.generating_status!

    students = fetch_students
    pdf_blob = render_batch_pdf(students)

    attach_file(pdf_blob)
    batch.complete_status!
  rescue StandardError => e
    batch.failed_status!
    Rails.logger.error "Batch #{batch.id} failed: #{e.message}"
    raise
  end

  private

  attr_reader :batch, :cutoff

  def fetch_students
    Student
      .where(school_id: batch.school_id)
      .with_recent_results(cutoff)
      .select  { |s| LevelBucket.for(s.level) == batch.level }
      .sort_by { |s| s.en_name }
  end

  def render_batch_pdf(students)
    html = ApplicationController.render(
      template: 'report_card_batches/batch_print_version',
      layout: 'pdf',
      assigns: { students: }
    )
    Grover.new(html, **StudentReportPdf.pdf_options).to_pdf
  end

  def attach_file(pdf_blob)
    batch.file.purge if batch.file.attached?
    batch.file.attach(
      io: StringIO.new(pdf_blob),
      filename: "report_#{batch.level}.pdf",
      content_type: 'application/pdf'
    )
  end
end
