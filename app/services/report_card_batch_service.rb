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
      .preload(test_results: :test)
      .select  { |s| tested_level_bucket(s) == batch.level }
      .sort_by { |s| s.en_name }
  end

  # Saving a result promotes the student straight away, so bucket by the test
  # they sat (or the level they were in when they sat it), not their new level.
  def tested_level_bucket(student)
    result = student.test_results
                    .select { |r| r.created_at >= cutoff }
                    .max_by(&:created_at)
    return LevelBucket.for(student.level) unless result

    LevelBucket.for(result.test&.level) || LevelBucket.for(result.prev_level)
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
