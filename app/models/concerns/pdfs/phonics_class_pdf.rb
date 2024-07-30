# frozen_string_literal: true

module PhonicsClassPdf
  extend ActiveSupport::Concern
  include PdfBodyItem, PdfLinks, PdfList

  BACKGROUND_PATH =
    Rails.root.join('app/assets/pdf_backgrounds/phonics.png').to_s
  HEADER_INDENT = 21.mm

  included do
    private

    def generate_guide
      Prawn::Document.new(
        margin: 0, page_size: 'A4', page_layout: :portrait
      ) do |pdf|
        apply_defaults(pdf)
        pdf.image BACKGROUND_PATH, at: [0, PAGE_HEIGHT],
                                   height: PAGE_HEIGHT, width: PAGE_WIDTH
        draw_header(pdf)
        add_image(pdf)
        draw_body(pdf)
        draw_footer_level(pdf)
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
        pdf.text title, size: HEADING_SIZE, overflow: :shrink_to_fit
      end
    end

    def draw_goal(pdf)
      pdf.bounding_box([HEADER_INDENT, 252.mm], width: 90.mm, height: 12.mm) do
        pdf.text goal, size: SUBHEADING_SIZE, overflow: :shrink_to_fit
      end
    end

    def draw_body(pdf)
      factory = PdfBodyItemFactory.new(pdf)

      factory.draw(text: array_to_list(materials, :number),
                   y_pos: 222.mm, height: 25.mm)
      factory.draw(text: array_to_list(instructions, :number),
                   y_pos: 180.mm, height: 35.mm)
      factory.draw(text: array_to_list(add_difficulty, :dot),
                   y_pos: 133.mm, height: 20.mm)
      factory.draw(text: array_to_list(extra_fun, :dot),
                   y_pos: 103.mm, height: 23.mm)
      factory.draw(text: array_to_list(notes, :dot),
                   y_pos: 70.mm, height: 20.mm)
      factory.draw(text: links_from_hash(links),
                   y_pos: 40.mm, height: 20.mm)
    end

    def draw_footer_level(pdf)
      pdf.bounding_box([140.mm, 7.mm], width: 66.mm, height: 10.mm) do
        pdf.text 'Elementary', color: 'FFFFFF', align: :right
      end
    end
  end
end
