# frozen_string_literal: true

module PdfList
  include PdfDefaults, PdfRoundedBorder

  def pdf_list(
    array:,
    dimensions:,
    pdf:,
    title:,
    type:
  )
    pdf.bounding_box(
      [0, pdf.cursor],
      height: dimensions[:height],
      width: dimensions[:width]
    ) do
      add_border(pdf, dimensions)
      add_title(pdf, title)
      create_list(array, dimensions, type, pdf)
    end
    pdf.move_down GAP
  end

  def add_title(pdf, title)
    pdf.move_down PADDING
    pdf.text title, size: HEADING_SIZE, indent_paragraphs: PADDING
    pdf.move_down PADDING
  end

  def create_list(array, dimensions, type, pdf)
    pdf.text_box(
      array_to_list(array, type),
      at: [PADDING * 2,
           dimensions[:height] - HEADING_SIZE - (PADDING * 2)],
      height: dimensions[:height],
      width: dimensions[:width],
      overflow: :shrink_to_fit
    )
  end

  def array_to_list(array, style = nil)
    case style
    when :number
      array.map.with_index { |step, i| "#{i + 1}. #{step}" }
           .join("\n")
    when :dot
      array.map { |step| "• #{step}" }.join("\n")
    else
      array.join("\n")
    end
  end
end
