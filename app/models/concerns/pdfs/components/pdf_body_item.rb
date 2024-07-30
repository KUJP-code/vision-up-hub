# frozen_string_literal: true

module PdfBodyItem
  class PdfBodyItemFactory
    include PdfDefaults

    def initialize(pdf)
      @pdf = pdf
      @body_width = 140.mm
      @body_indent = 48.mm
    end

    def draw(text:, y_pos:, height:, indent: @body_indent, width: @body_width)
      @pdf.bounding_box([indent, y_pos], width:, height:) do
        @pdf.text text,
                  size: FONT_SIZE, overflow: :shrink_to_fit,
                  inline_format: true
      end
    end
  end
end
