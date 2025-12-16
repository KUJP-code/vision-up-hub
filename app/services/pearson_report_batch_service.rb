# frozen_string_literal: true

require 'grover'

class PearsonReportBatchService
  LEVEL_MAP = {
    'kindy' => %w[kindy],
    'land' => %w[land_one land_two land_three],
    'sky' => %w[sky_one sky_two sky_three],
    'galaxy' => %w[galaxy_one galaxy_two galaxy_three],
    'evening' => Levels::EVENING_COURSES,
    'school' => Levels::LEVELS.keys.map(&:to_s)
  }.freeze

  def initialize(batch)
    @batch = batch
  end

  def call
    batch.generating_status!

    students = fetch_students
    pdf_blob = render_batch_pdf(students)

    attach_file(pdf_blob)
    batch.complete_status!
  rescue StandardError => e
    batch.failed_status!
    Rails.logger.error "Pearson batch #{batch.id} failed: #{e.message}"
    raise
  end

  private

  attr_reader :batch

  def fetch_students
    Student
      .joins(:pearson_results)
      .where(school_id: batch.school_id, level: levels_for_batch)
      .distinct
      .includes(:pearson_results)
      .sort_by { |student| [level_order(student), student.en_name] }
  end

  def render_batch_pdf(students)
    html = ApplicationController.render(
      template: 'report_card_batches/pearson_batch_print_version',
      layout: 'pdf',
      assigns: { students: }
    )
    Grover.new(html, **StudentReportPdf.pdf_options).to_pdf
  end

  def attach_file(pdf_blob)
    batch.file.purge if batch.file.attached?
    batch.file.attach(
      io: StringIO.new(pdf_blob),
      filename: 'pearson_report.pdf',
      content_type: 'application/pdf'
    )
  end

  def levels_for_batch
    LEVEL_MAP.fetch(batch.level) do
      raise ArgumentError, "Unknown Pearson batch level: #{batch.level}"
    end
  end

  def level_order(student)
    Levels::LEVEL_ORDER_MAP.fetch(student.level, Float::INFINITY)
  end
end
