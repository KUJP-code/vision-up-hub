# frozen_string_literal: true

module ExercisePdf
  extend ActiveSupport::Concern
  include PdfBackground, PdfBodyItem, PdfFooter, PdfHeaderItem, PdfImage, PdfImagePage, PdfLanguageGoals, PdfList

  included do
    private

    def generate_guide
      Prawn::Document.new(margin: 0, page_size: 'A4',
                          page_layout: :portrait) do |pdf|
        apply_defaults(pdf)
        add_background(pdf, 'daily_activity')
        draw_header(pdf)
        add_header_image(pdf)
        draw_lang_goals(pdf:)
        draw_body(pdf)
        level = kindy? ? 'Kindy' : 'Elementary'
        draw_footer(pdf:, level:, page_num: image_page ? '1' : nil)
        add_image_page(pdf:, image: image_page,
                       text: { pre: subtype.titleize, main: title,
                               sub: 'Photo guide', level: } )
      end
    end
  end

  def draw_header(pdf)
    factory = PdfHeaderItemFactory.new(pdf)
    factory.draw_default_header(text:
                                { pre: subtype.titleize,
                                  main: title, sub: goal })
    return if warning.blank?

    pdf.bounding_box([HEADER_INDENT, 240.mm],
                     width: 90.mm, height: 10.mm) do
      pdf.text warning, color: RED, overflow: :shrink_to_fit,
                        min_font_size: 0
    end
  end

  def add_header_image(pdf)
    factory = PdfImageFactory.new(pdf:, x_pos: 120.mm, width: 70.mm)
    factory.add_image(image: pdf_image, y_pos: 282.mm, height: 46.mm)
  end

  def draw_body(pdf)
    factory = PdfBodyItemFactory.new(pdf)

    factory.draw(text: array_to_list(materials, :number),
                y_pos: 191.mm, height: 30.mm)

    intro_items = Array(intro).compact
    if interesting_fact.present?
      intro_items << "Did you know? #{interesting_fact}"
    end
    intro_height = interesting_fact.present? ? 29.mm : 20.mm

    factory.draw(text: array_to_list(intro_items, :dot),
                y_pos: 149.mm, height: intro_height)

    instr_text = array_to_list(instructions, :number)

    tips      = Array(large_groups).compact
    tips_text = ""
    if tips.any?
      indent = "\u2002" # thin space ~1mm-ish
      tips_block = array_to_list(tips, :dot).gsub(/^/, indent)
      tips_text = "Large group tips:\n" + tips_block
    end

    body_text = [instr_text, tips_text.presence].compact.join("\n")

    factory.draw(text: body_text,
                y_pos: 110.mm, height: 50.mm)

    # Outro (unchanged)
    factory.draw(text: array_to_list(outro, :dot),
                y_pos: 52.mm, height: 30.mm)
  end
end
