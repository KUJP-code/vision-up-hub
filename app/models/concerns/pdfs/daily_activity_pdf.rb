# frozen_string_literal: true

module DailyActivityPdf
  extend ActiveSupport::Concern
  include PdfList

  BACKGROUND_PATH = Rails.root.join('app/assets/pdf_backgrounds/daily_activity.png').to_s
  BODY_INDENT = 47.mm
  HEADER_INDENT = 20.mm

  included do
    private

    def generate_guide
      Prawn::Document.new(
        margin: 0, page_size: 'A4', page_layout: :portrait
      ) do |pdf|
        apply_defaults(pdf)
        pdf.image BACKGROUND_PATH, at: [0, PAGE_HEIGHT],
                                   height: PAGE_HEIGHT, width: PAGE_WIDTH
        draw_subtype(pdf)
        draw_title(pdf)
        draw_goal(pdf)
        add_image(pdf)
        draw_lang_goals(pdf)
        draw_materials(pdf)
        draw_intro(pdf)
        draw_instructions(pdf)
        draw_large_groups(pdf)
        draw_outro(pdf)
        draw_footer_level(pdf)
      end
    end
  end

  def draw_subtype(pdf)
    pdf.bounding_box([HEADER_INDENT, 279.mm],
                     width: 41.mm, height: 3.mm) do
      pdf.text subtype.titleize, overflow: :shrink_to_fit
    end
  end

  def draw_title(pdf)
    pdf.bounding_box([HEADER_INDENT, 272.mm], width: 90.mm, height: 10.mm) do
      pdf.text title, size: HEADING_SIZE, overflow: :shrink_to_fit
    end
  end

  def draw_goal(pdf)
    pdf.bounding_box([HEADER_INDENT, 261.mm], width: 90.mm, height: 15.mm) do
      pdf.text goal, size: SUBHEADING_SIZE, overflow: :shrink_to_fit
    end
    return if warning.blank?

    draw_warning(pdf)
  end

  def draw_warning(pdf)
    pdf.bounding_box([HEADER_INDENT, 246.mm - PADDING],
                     width: 88.mm, height: 8.mm) do
      pdf.text warning, color: RED, overflow: :shrink_to_fit
    end
  end

  def draw_lang_goals(pdf)
    x_position = HEADER_INDENT + 2.mm

    [land_lang_goals, sky_lang_goals, galaxy_lang_goals].each do |goals|
      pdf.bounding_box([x_position, 220.mm], width: 51.mm, height: 11.mm) do
        pdf.text array_to_list(goals),
                 size: FONT_SIZE,
                 overflow: :shrink_to_fit
      end
      x_position += 58.mm
    end
  end

  def draw_materials(pdf)
    pdf.bounding_box([BODY_INDENT, 193.mm], width: 140.mm, height: 30.mm) do
      pdf.text array_to_list(materials, :number),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_intro(pdf)
    pdf.bounding_box([BODY_INDENT, 150.mm], width: 140.mm, height: 20.mm) do
      pdf.text array_to_list(intro, :dot),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end

    pdf.bounding_box([50.mm, 127.mm], width: 138.mm, height: 10.mm) do
      pdf.text "Did you know? #{interesting_fact}",
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_instructions(pdf)
    pdf.bounding_box([BODY_INDENT, 111.mm], width: 140.mm, height: 40.mm) do
      pdf.text array_to_list(instructions, :number),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_large_groups(pdf)
    pdf.bounding_box([BODY_INDENT, 71.mm], width: 140.mm, height: 10.mm) do
      pdf.text array_to_list(large_groups, :dot),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_outro(pdf)
    pdf.bounding_box([BODY_INDENT, 53.mm], width: 140.mm, height: 30.mm) do
      pdf.text array_to_list(outro, :dot),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_footer_level(pdf)
    pdf.bounding_box([140.mm, 7.mm], width: 66.mm, height: 10.mm) do
      pdf.text kindy? ? 'Kindergarten' : 'Elementary', color: 'FFFFFF', align: :right
    end
  end
end
