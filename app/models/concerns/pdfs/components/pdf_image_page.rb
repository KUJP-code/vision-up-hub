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
    factory.draw_default_header(text:)
  end
end
