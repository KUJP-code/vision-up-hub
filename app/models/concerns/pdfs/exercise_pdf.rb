# frozen_string_literal: true

module ExercisePdf
  extend ActiveSupport::Concern
  include PdfBodyItem, PdfFooter, PdfHeaderItem, PdfLanguageGoals, PdfList

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
    pdf.image background_path,
              at: [0, PAGE_HEIGHT], height: PAGE_HEIGHT,
              width: PAGE_WIDTH
    draw_header(pdf)
    draw_lang_goals(pdf:, y_start: 227.mm)
    draw_body(pdf)
    add_page_one_images(pdf:)
  end

  def add_page_two(pdf)
    background_path =
      Rails.root.join('app/assets/pdf_backgrounds/exercise_page_two.png').to_s
    pdf.image background_path,
              at: [0, PAGE_HEIGHT], height: PAGE_HEIGHT,
              width: PAGE_WIDTH
  end

  def draw_header(pdf)
    factory = PdfHeaderItemFactory.new(pdf)
    factory.draw_default_header(text:
                                { pre: subtype.titleize,
                                  main: title, sub: goal })
    return if warning.blank?

    pdf.bounding_box([HEADER_INDENT, 244.mm],
                     width: 88.mm, height: 8.mm) do
      pdf.text warning, color: RED, overflow: :shrink_to_fit,
                        min_font_size: 0
    end
  end
end
