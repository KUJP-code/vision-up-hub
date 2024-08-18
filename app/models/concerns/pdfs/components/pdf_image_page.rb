# frozen_string_literal: true

module PdfImagePage
  include PdfBackground, PdfDefaults, PdfFooter, PdfHeaderItem, PdfImage

  def add_image_page(pdf:, text:, image:)
    return unless image.attached?

    pdf.start_new_page
    add_background(pdf, 'image_page')
    draw_img_page_header(pdf:, text:)
    add_image(pdf, image)
    draw_footer(pdf:, level: text[:level], page_num: '2')
  end

  private

  def draw_img_page_header(pdf:, text:)
    factory = PdfHeaderItemFactory.new(pdf)
    factory.draw_default_header(text:)
  end

  def add_image(pdf, image)
    factory = PdfImageFactory.new(pdf:, x_pos: 25.mm, width: 160.mm)
    factory.add_image(image:, y_pos: 247.mm, height: 220.mm)
  end
end
