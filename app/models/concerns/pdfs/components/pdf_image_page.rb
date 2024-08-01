# frozen_string_literal: true

module PdfImagePage
  include PdfDefaults, PdfFooter, PdfHeaderItem

  BACKGROUND_PATH =
    Rails.root.join('app/assets/pdf_backgrounds/image_page.png').to_s

  def add_image_page(pdf:, text:, image:)
    return unless image.attached?

    pdf.start_new_page
    pdf.image BACKGROUND_PATH,
              at: [0, PAGE_HEIGHT], height: PAGE_HEIGHT,
              width: PAGE_WIDTH
    draw_img_page_header(pdf:, text:)
    image.blob.open do |file|
      pdf.image(file.path, position: 25.mm, vposition: 50.mm,
                           width: 160.mm, height: 220.mm)
    end
    draw_footer(pdf:, level: text[:level], page_num: '2')
  end

  private

  def draw_img_page_header(pdf:, text:)
    factory = PdfHeaderItemFactory.new(pdf)
    factory.draw_default_header(text:)
  end
end
