# frozen_string_literal: true

module DailyActivityPdf
  extend ActiveSupport::Concern
  include PdfBodyItem, PdfFooter, PdfHeaderItem, PdfImage, PdfImagePage, PdfLanguageGoals, PdfList

  BACKGROUND_PATH =
    Rails.root.join('app/assets/pdf_backgrounds/daily_activity.png').to_s

  included do
    private

    def generate_guide
      Prawn::Document.new(margin: 0, page_size: 'A4',
                          page_layout: :portrait) do |pdf|
        apply_defaults(pdf)
        pdf.image BACKGROUND_PATH,
                  at: [0, PAGE_HEIGHT], height: PAGE_HEIGHT,
                  width: PAGE_WIDTH
        draw_header(pdf)
        add_header_image(pdf)
        draw_lang_goals(pdf:, y_start: 220.mm)
        draw_body(pdf)
        draw_footer(pdf:,
                    level: kindy? ? 'Kindergarten' : 'Elementary',
                    page_num: image_page ? '1' : nil)
        add_image_page(pdf:, image: image_page,
                       text: { pre: subtype.titleize, main: title,
                               sub: 'Photo guide' })
      end
    end
  end

  def draw_header(pdf)
    factory = PdfHeaderItemFactory.new(pdf)
    factory.draw_default_header(text:
                                { pre: subtype.titleize,
                                  main: title, sub: goal })
    return if warning.blank?

    pdf.bounding_box([HEADER_INDENT, 244.mm],
                     width: 88.mm, height: 8.mm) do
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
                 y_pos: 193.mm, height: 30.mm)
    factory.draw(text: array_to_list(intro, :dot),
                 y_pos: 150.mm, height: 20.mm)
    factory.draw(text: "Did you know? #{interesting_fact}",
                 y_pos: 127.mm, height: 10.mm,
                 indent: 50.mm, width: 138.mm)
    factory.draw(text: array_to_list(instructions, :number),
                 y_pos: 111.mm, height: 40.mm)
    factory.draw(text: array_to_list(large_groups, :dot),
                 y_pos: 71.mm, height: 10.mm)
    factory.draw(text: array_to_list(outro, :dot),
                 y_pos: 53.mm, height: 30.mm)
  end
end
