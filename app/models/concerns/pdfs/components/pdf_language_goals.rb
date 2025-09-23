# frozen_string_literal: true

module PdfLanguageGoals
  include PdfDefaults

  def draw_lang_goals(pdf:)
    x_position = HEADER_INDENT + 2.mm

    [sa(land_lang_goals), sa(sky_lang_goals), sa(galaxy_lang_goals)].each do |goals|
      pdf.bounding_box([x_position, 220.mm], width: 51.mm, height: 11.mm) do
        pdf.text array_to_list(goals),
                 size: FONT_SIZE,
                 overflow: :shrink_to_fit,
                 min_font_size: 0
      end
      x_position += 58.mm
    end
  end
end
