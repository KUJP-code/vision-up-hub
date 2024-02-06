# frozen_string_literal: true

module DailyActivityPdf
  extend ActiveSupport::Concern
  include PdfDefaults, PdfHeader, PdfLinks, PdfNumList

  included do
    private

    def generate_guide
      pdf = Prawn::Document.new

      pdf_header(pdf, subtitle: subtype.capitalize)
      pdf_num_list(
        array: steps,
        dimensions: { height: 5.cm, width: pdf.bounds.width },
        pdf:,
        title: 'Steps:'
      )
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
