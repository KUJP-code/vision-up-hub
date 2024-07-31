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
        factory = PdfBodyItemFactory.new(pdf)
        add_page_one(pdf, factory)
        pdf.start_new_page
        add_page_two(pdf, factory)
      end
    end
  end

  def add_page_one(pdf, factory)
    background_path =
      Rails.root.join('app/assets/pdf_backgrounds/exercise_page_one.png').to_s
    pdf.image background_path,
              at: [0, PAGE_HEIGHT], height: PAGE_HEIGHT,
              width: PAGE_WIDTH
    draw_header(pdf)
    draw_lang_goals(pdf:, y_start: 227.mm)

    draw_page_one_body(factory)
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

  def draw_page_one_body(factory)
    factory.draw(text: array_to_list(materials, :number),
                 y_pos: 200.mm, height: 16.mm)
    factory.draw(text: array_to_list(cardio_and_stretching, :number),
                 y_pos: 175.mm, height: 20.mm)
    factory.draw(text: array_to_list(form_practice, :number),
                 y_pos: 93.mm, height: 35.mm)
  end

  def add_page_two(pdf, factory)
    background_path =
      Rails.root.join('app/assets/pdf_backgrounds/exercise_page_two.png').to_s
    pdf.image background_path,
              at: [0, PAGE_HEIGHT], height: PAGE_HEIGHT,
              width: PAGE_WIDTH
    draw_page_two_body(factory)
  end

  def draw_page_two_body(factory)
    factory.draw(text: array_to_list(instructions, :number),
                 y_pos: 270.mm, height: 60.mm)
    factory.draw(text: array_to_list(cooldown_and_recap, :number),
                 y_pos: 100.mm, height: 20.mm)
  end
end
