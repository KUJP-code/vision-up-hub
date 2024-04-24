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
        draw_title(pdf)
        draw_goal(pdf)
      end
    end
  end

  def draw_subtype(pdf)
    pdf.bounding_box([27.mm, 281.mm], width: 41.mm, height: 5.mm) do
      pdf.text subtype.titleize
    end
  end

  def draw_title(pdf)
    pdf.bounding_box([26.mm, 272.mm], width: 90.mm, height: 10.mm) do
      pdf.text title, size: HEADING_SIZE
    end
  end

  def draw_goal(pdf)
    pdf.bounding_box([26.mm, 261.mm], width: 90.mm, height: 10.mm) do
      pdf.text goal, size: SUBHEADING_SIZE
    end
  end
end
