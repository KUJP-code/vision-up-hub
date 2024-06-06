# frozen_string_literal: true

module PhonicsClassPdf
  extend ActiveSupport::Concern
  include PdfLinks, PdfList

  BACKGROUND_PATH = Rails.root.join('app/assets/pdf_backgrounds/phonics.png').to_s
  BODY_INDENT = 48.mm
  HEADER_INDENT = 21.mm

  included do
    private

    def generate_guide
      Prawn::Document.new(margin: 0, page_size: 'A4', page_layout: :portrait) do |pdf|
        apply_defaults(pdf)
        pdf.image BACKGROUND_PATH, height: 297.mm, width: 210.mm
        draw_header(pdf)
        add_image(pdf)
      end
    end

    def draw_header(pdf)
      draw_level(pdf)
      draw_title(pdf)
      draw_goal(pdf)
    end

    def draw_level(pdf)
      pdf.bounding_box([HEADER_INDENT, 280.mm], width: 90.mm, height: 4.mm) do
        pdf.text "#{short_level.upcase} Phonics",
                 size: SUBHEADING_SIZE, overflow: :shrink_to_fit
      end
    end

    def draw_title(pdf)
      pdf.bounding_box([HEADER_INDENT, 272.mm], width: 90.mm, height: 20.mm) do
        pdf.stroke_bounds
        pdf.text title, size: HEADING_SIZE, overflow: :shrink_to_fit
      end
    end

    def draw_goal(pdf)
      pdf.bounding_box([HEADER_INDENT, 252.mm], width: 90.mm, height: 12.mm) do
        pdf.stroke_bounds
        pdf.text goal, size: SUBHEADING_SIZE, overflow: :shrink_to_fit
      end
    end
  end
end
