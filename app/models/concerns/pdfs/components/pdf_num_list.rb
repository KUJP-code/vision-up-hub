# frozen_string_literal: true

module PdfNumList
  def pdf_num_list(
    array:,
    dimensions:,
    pdf:,
    title:,
    coords: [0, pdf.cursor]
  )
    pdf.bounding_box(
      coords,
      height: dimensions[:height],
      width: dimensions[:width]
    ) do
      add_border(pdf, dimensions)
      add_title(pdf, title)
      create_list(array, dimensions, pdf)
    end
    pdf.move_down 0.5.cm
  end

  private

  def add_border(pdf, dimensions)
    pdf.stroke do
      pdf.rounded_rectangle [0, pdf.cursor], dimensions[:width], dimensions[:height], 0.5.cm
    end
  end

  def add_title(pdf, title)
    pdf.move_down 0.25.cm
    pdf.text title, size: 0.5.cm
    pdf.move_down 0.25.cm
  end

  def create_list(array, dimensions, pdf)
    pdf.text_box(
      array.join("\n"),
      at: [0, dimensions[:height] - 1.cm],
      height: dimensions[:height],
      width: dimensions[:width],
      overflow: :shrink_to_fit
    )
  end
end
