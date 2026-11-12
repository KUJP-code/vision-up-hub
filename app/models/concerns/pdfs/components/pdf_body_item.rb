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
        @pdf.formatted_text wrappable_text(text),
                            size: FONT_SIZE, overflow: :shrink_to_fit,
                            min_font_size: 0
      end
    end

    private

    def wrappable_text(text)
      # Parse markup first so wrap points never change links or formatting tags.
      @pdf.text_formatter.format(text).each do |fragment|
        # Prawn otherwise treats Japanese text without spaces as one long word.
        fragment[:text] = fragment[:text].gsub(
          /([\p{Han}\p{Hiragana}\p{Katakana}ー])(?![、。，．！？!?）」』】ぁぃぅぇぉっゃゅょゎァィゥェォッャュョヮヵヶー])/,
          "\\1\u200B"
        )
      end
    end
  end
end
