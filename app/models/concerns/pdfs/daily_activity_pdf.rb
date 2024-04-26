# frozen_string_literal: true

module DailyActivityPdf
  extend ActiveSupport::Concern
  include PdfDefaults, PdfHeader, PdfLinks, PdfList

  BACKGROUND_PATH = Rails.root.join('app/assets/pdf_backgrounds/daily_activity.png').to_s

  included do
    private

    def generate_guide
      Prawn::Document.new(margin: 0, page_size: 'A4', page_layout: :portrait) do |pdf|
        pdf.image BACKGROUND_PATH, height: 297.mm, width: 210.mm
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
    pdf.bounding_box([27.mm, 281.mm], width: 41.mm, height: 5.mm) do
      pdf.text subtype.titleize
    end
  end

  def draw_title(pdf)
    pdf.bounding_box([26.mm, 272.mm], width: 90.mm, height: 10.mm) do
      pdf.text title, size: HEADING_SIZE
    end
  end

  def draw_goal(pdf)
    pdf.bounding_box([26.mm, 261.mm], width: 90.mm, height: 10.mm) do
      pdf.text goal, size: SUBHEADING_SIZE
    end
  end

  def add_image(pdf)
    return unless pdf_image.attached?

    pdf_image.blob.open do |file|
      pdf.image(
        file.path,
        position: 124.mm,
        vposition: 15.mm,
        width: 200,
        height: 131
      )
    end
  end

  def draw_lang_goals(pdf)
    x_position = 26.mm

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
    pdf.bounding_box([52.mm, 190.mm], width: 140.mm, height: 30.mm) do
      pdf.text array_to_list(materials, :number),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_intro(pdf)
    pdf.bounding_box([52.mm, 147.mm], width: 140.mm, height: 20.mm) do
      pdf.text array_to_list(intro, :dot),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end

    pdf.bounding_box([54.mm, 127.mm], width: 138.mm, height: 10.mm) do
      pdf.text "Did you know? #{interesting_fact}",
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_instructions(pdf)
    pdf.bounding_box([52.mm, 110.mm], width: 140.mm, height: 40.mm) do
      pdf.text array_to_list(instructions, :number),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_large_groups(pdf)
    pdf.bounding_box([52.mm, 70.mm], width: 140.mm, height: 10.mm) do
      pdf.text array_to_list(large_groups, :dot),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_outro(pdf)
    pdf.bounding_box([52.mm, 50.mm], width: 140.mm, height: 30.mm) do
      pdf.text array_to_list(outro, :dot),
               size: FONT_SIZE,
               overflow: :shrink_to_fit
    end
  end

  def draw_footer_level(pdf)
    pdf.bounding_box([140.mm, 6.mm], width: 66.mm, height: 10.mm) do
      pdf.text kindy? ? 'Kindergarten' : 'Elementary', color: 'FFFFFF', align: :right
    end
  end
end
