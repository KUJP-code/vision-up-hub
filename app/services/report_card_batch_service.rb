# frozen_string_literal: true

require 'grover/browser'

class ReportCardBatchService
  RECENT_WINDOW = 3.months

  def initialize(batch)
    @batch = batch
    @cutoff = RECENT_WINDOW.ago
  end

  def call
    batch.generating_status!

    students = fetch_students
    pdf_blob = merge_pdfs(students)

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

  def merge_pdfs(students)
    combined = CombinePDF.new
    browser = build_browser

    students.each do |student|
      combined << CombinePDF.parse(render_page(student, browser:))
    end

    combined.to_pdf
  ensure
    browser&.close
  end

  def attach_file(pdf_blob)
    batch.file.purge if batch.file.attached?
    batch.file.attach(
      io: StringIO.new(pdf_blob),
      filename: "report_#{batch.level}.pdf",
      content_type: 'application/pdf'
    )
  end

  def render_page(student, browser: nil)
    StudentReportPdf.new(student).call(browser:)
  end

  def build_browser
    Grover::Browser.new
  rescue StandardError => e
    Rails.logger.warn("ReportCardBatchService fell back to per-student browser instances: #{e.message}")
    nil
  end
end
