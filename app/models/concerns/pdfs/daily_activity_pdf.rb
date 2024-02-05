# frozen_string_literal: true

module DailyActivityPdf
  extend ActiveSupport::Concern
  include PdfHeader, PdfNumList

  included do
    private

    def generate_guide
      pdf = Prawn::Document.new

      pdf_header(pdf)
      pdf.text subtype.capitalize
      pdf_num_list(
        array: steps,
        dimensions: { height: 5.cm, width: pdf.bounds.width },
        pdf:,
        title: 'Steps:'
      )
      pdf.text 'Links:', size: 18
      links.each do |k, v|
        pdf.text "<color rgb='0000FF'><u><link href='#{v}'>#{k}</link></u></color>", inline_format: true
      end

      pdf
    end
  end
end
