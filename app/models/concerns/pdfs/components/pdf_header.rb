# frozen_string_literal: true

module PdfHeader
  def pdf_header(pdf)
    pdf.bounding_box(
      [pdf.bounds.left, pdf.bounds.top],
      height: 1.cm, width: pdf.bounds.width
    ) do
      pdf.stroke_bounds
      pdf.move_down 0.25.cm
      pdf.text title, align: :center, size: 0.5.cm
    end
    pdf.move_down 0.5.cm
  end
end
