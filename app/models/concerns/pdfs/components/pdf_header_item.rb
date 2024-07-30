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
        @pdf.text text, size:, overflow: :shrink_to_fit, min_font_size: 0
      end
    end
  end
end
