# frozen_string_literal: true

module DailyActivityPdf
  extend ActiveSupport::Concern
  include PdfDefaults, PdfHeader, PdfLinks, PdfList

  BACKGROUND_PATH = Rails.root.join('app/assets/pdf_backgrounds/daily_activity.png').to_s

  included do
    private

    def generate_guide
      Prawn::Document.new(margin: 0, page_size: 'A4', page_layout: :portrait) do |pdf|
        pdf.image BACKGROUND_PATH, fit: [210.mm, 297.mm]
      end
    end
  end
end
