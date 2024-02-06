# frozen_string_literal: true

module PdfRoundedBorder
  include PdfDefaults

  def add_border(pdf, dimensions)
    pdf.stroke do
      pdf.rounded_rectangle [0, pdf.cursor], dimensions[:width], dimensions[:height], BORDER_RADIUS
    end
  end
end
