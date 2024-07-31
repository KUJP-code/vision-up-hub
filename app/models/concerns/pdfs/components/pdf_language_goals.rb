# frozen_string_literal: true

module PdfLanguageGoals
  include PdfDefaults

  def draw_lang_goals(pdf:, y_start:)
    x_position = HEADER_INDENT + 2.mm

    [land_lang_goals, sky_lang_goals, galaxy_lang_goals].each do |goals|
      pdf.bounding_box([x_position, y_start], width: 51.mm, height: 11.mm) do
        pdf.text array_to_list(goals),
                 size: FONT_SIZE,
                 overflow: :shrink_to_fit,
                 min_font_size: 0
      end
      x_position += 58.mm
    end
  end
end
