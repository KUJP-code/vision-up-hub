# frozen_string_literal: true

module ExercisePdf
  extend ActiveSupport::Concern
  include PdfHeader, PdfLinks, PdfList

  included do
    private

    def generate_guide
      pdf = Prawn::Document.new

      pdf_header(pdf)
      if guide_image.attached?
        guide_image.blob.open do |file|
          pdf.image(
            file.path,
            position: :right,
            vposition: :top,
            width: 200,
            height: 200
          )
        end
      end

      add_unordered_lists(pdf)
      add_ordered_lists(pdf)

      pdf_links(
        links:,
        dimensions: { height: 5.cm, width: pdf.bounds.width },
        pdf:,
        title: 'Links:'
      )

      pdf
    end
  end

  def add_unordered_lists(pdf)
    pdf_list(array: materials, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Materials:', type: :dot)
    pdf_list(array: notes, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Notes:', type: :dot)
    pdf_list(array: intro, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Intro:', type: :dot)
    pdf_list(array: extra_fun, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Extra Fun:', type: :dot)
    pdf_list(array: add_difficulty, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Add Difficulty:', type: :dot)
    pdf_list(array: outro, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Outro:', type: :dot)
  end

  def add_ordered_lists(pdf)
    pdf_list(array: steps, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Steps:', type: :number)
    pdf_list(array: instructions, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Instructions:', type: :number)
    pdf_list(array: large_groups, dimensions: { height: 3.cm, width: pdf.bounds.width },
             pdf:, title: 'Large Groups:', type: :number)
  end
end
