# frozen_string_literal: true

module PdfHeader
  include PdfDefaults

  def pdf_header(pdf, subtitle: nil)
    pdf.bounding_box(
      [pdf.bounds.left, pdf.bounds.top],
      height: subtitle ? 1.75.cm : 1.cm,
      width: pdf.bounds.width
    ) do
      pdf.stroke_bounds
      pdf.move_down PADDING
      pdf.text title, align: :center, size: HEADING_SIZE

      if subtitle
        pdf.move_down PADDING
        pdf.text subtitle, align: :center, size: SUBHEADING_SIZE
      end
    end
    pdf.move_down GAP
  end
end
