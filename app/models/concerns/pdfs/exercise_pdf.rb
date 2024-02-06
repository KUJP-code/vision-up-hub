# frozen_string_literal: true

module ExercisePdf
  extend ActiveSupport::Concern
  include PdfHeader, PdfLinks

  included do
    private

    def generate_guide
      pdf = Prawn::Document.new

      pdf_header(pdf)
      if image.attached?
        pdf.image(
          StringIO.open(image.download),
          position: :right,
          vposition: :top,
          width: 200,
          height: 200
        )
      end

      pdf_links(
        links:,
        dimensions: { height: 5.cm, width: pdf.bounds.width },
        pdf:,
        title: 'Links:'
      )

      pdf
    end
  end
end
