# frozen_string_literal: true

module PhonicsClassPdf
  extend ActiveSupport::Concern
  include PdfBackground, PdfBodyItem, PdfFooter, PdfHeaderItem, PdfImage, PdfLinks, PdfList

  PHONICS_BODY_INDENT = 42.mm
  PHONICS_MATERIALS_Y = 225.mm
  PHONICS_MATERIALS_H = 18.mm
  included do
    private

    def generate_guide
      Prawn::Document.new(margin: 0, page_size: 'A4',
                          page_layout: :portrait) do |pdf|
        apply_defaults(pdf)
        add_background(pdf, 'phonics')
        draw_header(pdf)
        add_header_image(pdf)
        draw_body(pdf)
        draw_footer(pdf:, level: 'Elementary')
      end
    end

    def draw_header(pdf)
      factory = PdfHeaderItemFactory.new(pdf)
      factory.draw_default_header(text:
        { pre: "#{short_level.upcase} Phonics",
          main: sa(title), sub: sa(goal) })
    end

    def add_header_image(pdf)
      factory = PdfImageFactory.new(pdf:, x_pos: 120.mm, width: 70.mm)
      factory.add_image(image: pdf_image, y_pos: 282.mm, height: 46.mm)
    end

    def draw_body(pdf)
      factory = PdfBodyItemFactory.new(pdf)

      draw_materials(pdf, factory:)
      factory.draw(text: array_to_list(sa(intro), :dot),
                   y_pos: 199.mm, height: 18.mm, indent: PHONICS_BODY_INDENT)
      factory.draw(text: array_to_list(sa(instructions), :number),
                   y_pos: 160.mm, height: 30.mm, indent: PHONICS_BODY_INDENT)
      factory.draw(text: array_to_list(sa(review), :dot),
                   y_pos: 130.mm, height: 18.mm, indent: PHONICS_BODY_INDENT)
      factory.draw(text: array_to_list(sa(add_difficulty), :dot),
                   y_pos: 105.mm, height: 18.mm, indent: PHONICS_BODY_INDENT)
      factory.draw(text: array_to_list(sa(extra_fun), :dot),
                   y_pos: 80.mm, height: 18.mm, indent: PHONICS_BODY_INDENT)
      factory.draw(text: links_from_hash(links),
                   y_pos: 40.mm, height: 20.mm, indent: PHONICS_BODY_INDENT)
    end

    def draw_materials(pdf, factory:)
      items = Array(materials).compact
      return if items.empty?

      y  = PHONICS_MATERIALS_Y
      h  = PHONICS_MATERIALS_H
      lx = PHONICS_BODY_INDENT
      w  = MATERIALS_TOTAL_W / 2.0
      rx = lx + w

      cutoff = (items.size / 2.0).ceil
      left   = items.first(cutoff)
      right  = items.drop(cutoff)

      factory.draw(
        text: sa(array_to_list(left, :number)),
        y_pos: y, height: h, indent: lx, width: w
      )

      factory.draw(
        text: renumber(array_to_list(right, :number), start_at: cutoff + 1),
        y_pos: y, height: h, indent: rx, width: w
      )
    end

    def renumber(numbered_text, start_at:)
      numbered_text
        .lines
        .map.with_index(start_at) { |t, i| t.sub(/^\d+/, i.to_s) }
        .join
    end
  end
end
