# frozen_string_literal: true

module PdfBackground
  include PdfDefaults

  def add_background(pdf, filename)
    path = Rails.root.join("app/assets/pdf_backgrounds/#{filename}.png").to_s
    pdf.image path,
              at: [0, PAGE_HEIGHT], height: PAGE_HEIGHT,
              width: PAGE_WIDTH
  end
end
