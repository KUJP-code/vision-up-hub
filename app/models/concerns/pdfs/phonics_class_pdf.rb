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
        pdf.image BACKGROUND_PATH, height: PAGE_HEIGHT, width: PAGE_WIDTH
        draw_header(pdf)
        add_image(pdf)
        draw_materials(pdf)
        draw_instructions(pdf)
        draw_difficulty(pdf)
        draw_extra_fun(pdf)
        draw_notes(pdf)
        draw_links(pdf)
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

    def draw_materials(pdf)
      pdf.bounding_box([BODY_INDENT, 222.mm], width: 140.mm, height: 25.mm) do
        pdf.text array_to_list(materials, :number),
                 size: FONT_SIZE,
                 overflow: :shrink_to_fit
      end
    end

    def draw_instructions(pdf)
      pdf.bounding_box([BODY_INDENT, 180.mm], width: 140.mm, height: 35.mm) do
        pdf.text array_to_list(instructions, :number),
                 size: FONT_SIZE,
                 overflow: :shrink_to_fit
      end
    end

    def draw_difficulty(pdf)
      pdf.bounding_box([BODY_INDENT, 133.mm], width: 140.mm, height: 20.mm) do
        pdf.text array_to_list(add_difficulty, :dot),
                 size: FONT_SIZE,
                 overflow: :shrink_to_fit
      end
    end

    def draw_extra_fun(pdf)
      pdf.bounding_box([BODY_INDENT, 103.mm], width: 140.mm, height: 23.mm) do
        pdf.text array_to_list(extra_fun, :dot),
                 size: FONT_SIZE,
                 overflow: :shrink_to_fit
      end
    end

    def draw_notes(pdf)
      pdf.bounding_box([BODY_INDENT, 70.mm], width: 140.mm, height: 20.mm) do
        pdf.text array_to_list(notes, :dot),
                 size: FONT_SIZE,
                 overflow: :shrink_to_fit
      end
    end

    def draw_links(pdf)
      pdf.bounding_box([BODY_INDENT, 40.mm], width: 140.mm, height: 20.mm) do
        links_from_pairs(links, pdf)
      end
    end

    def draw_footer_level(pdf)
      pdf.bounding_box([140.mm, 7.mm], width: 66.mm, height: 10.mm) do
        pdf.text 'Elementary', color: 'FFFFFF', align: :right
      end
    end
  end
end
