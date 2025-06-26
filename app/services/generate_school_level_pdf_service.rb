class GenerateSchoolLevelPdfService
  RECENT_WINDOW = 4.months

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
  rescue => e
    batch.failed_status!
    Rails.logger.error "Batch #{batch.id} failed: #{e.message}"
    raise
  end

  private

  attr_reader :batch, :cutoff

  # pick students of the right bucket with recent results
  def fetch_students
    Student
      .where(school_id: batch.school_id)
      .with_recent_results(cutoff)
      .select  { |s| LevelBucket.for(s.level) == batch.level }
      .sort_by { |s| s.en_name }
  end

  def merge_pdfs(students)
    combined = CombinePDF.new
    students.each { |student| combined << CombinePDF.parse(render_page(student)) }
    combined.to_pdf
  end

  def render_page(student)
    html = ApplicationController.render(
      template: 'students/print_version',
      layout:   'pdf',
      assigns:  { student: }
    )

    Grover
      .new(html,
           emulate_media: 'print',
           wait_for:      'window.chartReady === true',
           format:        'A4')
      .to_pdf
  end

  # overwrite any previous attachment
  def attach_file(pdf_blob)
    batch.file.purge if batch.file.attached?
    batch.file.attach(
      io: StringIO.new(pdf_blob),
      filename: "report_#{batch.level}.pdf",
      content_type: 'application/pdf'
    )
  end
end
