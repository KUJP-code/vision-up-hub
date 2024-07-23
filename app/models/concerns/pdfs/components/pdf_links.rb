# frozen_string_literal: true

module PdfLinks
  include PdfDefaults, PdfRoundedBorder

  def pdf_links(links:, dimensions:, pdf:, title:, coords: [0, pdf.cursor])
    pdf.bounding_box(
      coords,
      height: dimensions[:height],
      width: dimensions[:width]
    ) do
      add_border(pdf, dimensions)
      add_title(pdf, title)
      create_links(links, dimensions, pdf)
    end
  end

  def create_links(links, dimensions, pdf)
    pdf.text_box(
      links_from_pairs(links, pdf),
      at: [0, dimensions[:height] - HEADING_SIZE - (PADDING * 2)],
      height: dimensions[:height],
      width: dimensions[:width],
      overflow: :shrink_to_fit
    )
  end

  def links_from_pairs(links, pdf)
    link_array = links.map do |k, v|
      pdf.text "<color rgb='645880'><u><link href='#{v}'>#{k}</link></u></color>",
               inline_format: true,
               size: FONT_SIZE
    end
    link_array.join("\n")
  end
end
