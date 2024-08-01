# frozen_string_literal: true

module DailyActivityPdf
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
    factory.draw(text: array_to_list(intro, :dot),
                 y_pos: 149.mm, height: 20.mm)
    factory.draw(text: "Did you know? #{interesting_fact}",
                 y_pos: 127.mm, height: 9.mm,
                 indent: 50.mm, width: 138.mm)
    factory.draw(text: array_to_list(instructions, :number),
                 y_pos: 110.mm, height: 40.mm)
    factory.draw(text: array_to_list(large_groups, :dot),
                 y_pos: 70.mm, height: 10.mm)
    factory.draw(text: array_to_list(outro, :dot),
                 y_pos: 52.mm, height: 30.mm)
  end
end
