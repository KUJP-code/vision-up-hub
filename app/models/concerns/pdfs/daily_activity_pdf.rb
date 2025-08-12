# frozen_string_literal: true

module DailyActivityPdf
  extend ActiveSupport::Concern
  include PdfBackground, PdfBodyItem, PdfFooter, PdfHeaderItem, PdfImage, PdfImagePage, PdfLanguageGoals, PdfList, PdfDefaults
  attr_reader :body_width, :body_indent

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

    draw_materials(pdf, factory: factory)

    intro_items = Array(intro).compact
    intro_items << "Did you know? #{interesting_fact}" if interesting_fact.present?
    intro_height = interesting_fact.present? ? 29.mm : 20.mm
    factory.draw(
      text: array_to_list(intro_items, :dot),
      y_pos: 149.mm,
      height: intro_height
    )

    instr_text = array_to_list(instructions, :number)

    tips = Array(large_groups).compact
    tips_text = ""
    if tips.any?
      thin_space = "\u2002"
      tips_block = array_to_list(tips, :dot).gsub(/^/, thin_space)

      tips_text = "\nLarge group tips:\n" + tips_block
    end

    factory.draw(
      text: instr_text + tips_text,
      y_pos: 110.mm,
      height: 50.mm
    )

    factory.draw(
      text: array_to_list(outro, :dot),
      y_pos: 52.mm,
      height: 30.mm
    )
  end

  def draw_materials(pdf, factory:)
    items = Array(materials).compact
    return if items.empty?

    y  = MATERIALS_Y
    h  = MATERIALS_H
    lx = MATERIALS_LEFT_X
    w  = MATERIALS_TOTAL_W / 2.0
    rx = lx + w

    cutoff = (items.size / 2.0).ceil
    left   = items.first(cutoff)
    right  = items.drop(cutoff)

    factory.draw(
      text: array_to_list(left, :number),
      y_pos: y, height: h, indent: lx, width: w
    )

    factory.draw(
      text: renumber(array_to_list(right, :number), start_at: cutoff + 1),
      y_pos: y, height: h, indent: rx, width: w
    )
  end

  private

  def renumber(numbered_text, start_at:)
    numbered_text
      .lines
      .map.with_index(start_at) { |t, i| t.sub(/^\d+/, i.to_s) }
      .join
  end
end
