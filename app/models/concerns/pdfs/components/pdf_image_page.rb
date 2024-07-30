# frozen_string_literal: true

module PdfImagePage
  include PdfDefaults, PdfFooter, PdfHeaderItem

  def add_image_page(pdf:, text:, image:)
    return unless image.attached?

    pdf.start_new_page
    draw_img_page_header(pdf:, text:)
    image.blob.open do |file|
      pdf.image(file.path, position: 10.mm, vposition: 45.mm,
                           width: 190.mm, height: 230.mm)
    end
    draw_footer(pdf:, level: text[:level], page_num: '2')
  end

  private

  def draw_img_page_header(pdf:, text:)
    factory = PdfHeaderItemFactory.new(pdf)

    factory.draw(text: text[:pre], y_pos: 280.mm,
                 height: 3.mm, size: FONT_SIZE)
    factory.draw(text: text[:main], y_pos: 275.mm,
                 height: 10.mm, size: HEADING_SIZE)
    factory.draw(text: text[:sub], y_pos: 265.mm,
                 height: 15.mm, size: FONT_SIZE)
  end
end
