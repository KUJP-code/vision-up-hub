# frozen_string_literal: true

module PdfHeaderItem
  class PdfHeaderItemFactory
    include PdfDefaults

    def initialize(pdf)
      @pdf = pdf
      @header_width = 90.mm
      @header_indent = 20.mm
    end

    def draw(text:, y_pos:, height:, size:)
      @pdf.bounding_box([@header_indent, y_pos],
                        width: @header_width, height:) do
        valign = text == 'Photo guide' ? :top : :center
        @pdf.text text, size:, overflow: :shrink_to_fit,
                        min_font_size: 0, valign:
      end
    end

    def draw_default_header(text:)
      draw(text: sa(text)[:pre], y_pos: 280.mm,
           height: 4.mm, size: SUBHEADING_SIZE)
      draw(text: sa(text)[:main], y_pos: 275.mm - PADDING,
           height: 10.mm, size: HEADING_SIZE)
      draw(text: sa(text)[:sub], y_pos: 265.mm - (PADDING * 2),
           height: 20.mm, size: FONT_SIZE)
    end
  end
end
