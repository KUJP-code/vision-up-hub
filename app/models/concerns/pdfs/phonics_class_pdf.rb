# frozen_string_literal: true

module PhonicsClassPdf
  extend ActiveSupport::Concern
  include PdfDefaults, PdfHeader, PdfLinks, PdfList

  included do
    private

    def generate_guide
      pdf = Prawn::Document.new

      pdf_header(pdf)
      add_unordered_lists(pdf)
      add_ordered_lists(pdf)
      pdf_links(links:, dimensions: { height: 3.cm, width: pdf.bounds.width },
                pdf:, title: 'Links:')

      pdf
    end
  end

  def add_unordered_lists(pdf)
    pdf_list(array: extra_fun, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Extra Fun:', type: :dot)
    pdf_list(array: materials, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Materials:', type: :dot)
    pdf_list(array: notes, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Notes:', type: :dot)
    pdf_list(array: extra_fun, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Extra Fun:', type: :dot)
  end

  def add_ordered_lists(pdf)
    pdf_list(array: add_difficulty, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Add Difficulty:', type: :number)
    pdf_list(array: instructions, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Instructions:', type: :number)
  end
end
