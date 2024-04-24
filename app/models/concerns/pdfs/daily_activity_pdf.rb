# frozen_string_literal: true

module DailyActivityPdf
  extend ActiveSupport::Concern
  include PdfDefaults, PdfHeader, PdfLinks, PdfList

  BACKGROUND_PATH = Rails.root.join('app/assets/pdf_backgrounds/daily_activity.png').to_s

  included do
    private

    def generate_guide
      Prawn::Document.new(margin: 0, page_size: 'A4', page_layout: :portrait) do |pdf|
        pdf.image BACKGROUND_PATH, height: 297.mm, width: 210.mm
        draw_subtype(pdf)
      end
    end
  end

  def draw_subtype(pdf)
    pdf.bounding_box([27.mm, 281.mm], width: 41.mm, height: 5.mm) do
      pdf.text subtype
    end
  end
end
