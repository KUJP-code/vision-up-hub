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
        draw_footer(pdf:, level:, page_num: first_page_number(classroom_layouts, image_page))
        add_image_pages(pdf:, level:, sections: image_page_sections, shared_header: image_pages_header)
      end
    end
  end

  def image_pages_header
    { pre: subtype.titleize, main: title }
  end

  # Classroom layouts first (numbered if there's more than one), then the photo guide.
  def image_page_sections
    layouts = image_blobs(classroom_layouts)
    layout_sections = layouts.map.with_index(1) do |blob, i|
      label = layouts.one? ? 'Classroom Layout:' : "Classroom Layout #{i}:"
      { blob:, label:, header: { pre: subtype.titleize, main: label, sub: title } }
    end

    layout_sections + [
      { blob: image_blobs(image_page).first, label: 'Photo guide:',
        header: { pre: subtype.titleize, main: title, sub: 'Photo guide' } }
    ]
  end

  def draw_header(pdf)
    factory = PdfHeaderItemFactory.new(pdf)
    factory.draw_default_header(text:
                                { pre: subtype.titleize,
                                  main: title, sub: goal })
    return if warning.blank?

    pdf.bounding_box([HEADER_INDENT, 240.mm],
                     width: 90.mm, height: 10.mm) do
      pdf.text sa(warning), color: RED, overflow: :shrink_to_fit,
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
    intro_items << "Did you know? #{sa(interesting_fact)}" if interesting_fact.present?
    intro_height = interesting_fact.present? ? 29.mm : 20.mm

    factory.draw(text: array_to_list(sa(intro_items), :dot),
                 y_pos: 149.mm, height: intro_height)

    instr_text = array_to_list(sa(instructions), :number)

    tips      = Array(sa(large_groups)).compact
    tips_text = ''
    if tips.any?
      indent = "\u2002" # thin space ~1mm-ish
      tips_block = array_to_list(tips, :dot).gsub(/^/, indent)
      tips_text = "Large group tips:\n" + tips_block
    end

    body_text = [instr_text, tips_text.presence].compact.join("\n")

    factory.draw(text: body_text,
                 y_pos: 110.mm, height: 50.mm)

    # Outro (unchanged)
    factory.draw(text: array_to_list(sa(outro), :dot),
                 y_pos: 52.mm, height: 30.mm)
  end
end
