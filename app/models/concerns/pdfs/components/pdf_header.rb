# frozen_string_literal: true

module PdfHeader
  include PdfDefaults

  def pdf_header(pdf)
    pdf.bounding_box(
      [pdf.bounds.left, pdf.bounds.top],
      height: 1.cm, width: pdf.bounds.width
    ) do
      pdf.stroke_bounds
      pdf.move_down PADDING
      pdf.text title, align: :center, size: HEADING_SIZE
    end
    pdf.move_down GAP
  end
end
