# frozen_string_literal: true

module ExercisePdf
  extend ActiveSupport::Concern
  include PdfBodyItem, PdfFooter, PdfHeaderItem, PdfList

  HEADER_INDENT = 20.mm

  included do
    private

    def generate_guide
      Prawn::Document.new(margin: 0, page_size: 'A4',
                          page_layout: :portrait) do |pdf|
        apply_defaults(pdf)
        add_page_one(pdf)
        pdf.start_new_page
        add_page_two(pdf)
      end
    end
  end

  def add_page_one(pdf)
    background_path =
      Rails.root.join('app/assets/pdf_backgrounds/exercise_page_one.png').to_s
    pdf.image background_path, at: [0, PAGE_HEIGHT],
                               height: PAGE_HEIGHT, width: PAGE_WIDTH
  end

  def add_page_two(pdf)
    background_path =
      Rails.root.join('app/assets/pdf_backgrounds/exercise_page_two.png').to_s
    pdf.image background_path, at: [0, PAGE_HEIGHT],
                               height: PAGE_HEIGHT, width: PAGE_WIDTH
  end
end
