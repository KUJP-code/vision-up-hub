# frozen_string_literal: true

module PdfDefaults
  BORDER_RADIUS = 0.3.cm
  FONT_SIZE = 2.5.mm
  SECONDARY_COLOR = '645780'
  PADDING = 2.mm
  PAGE_HEIGHT = 297.mm
  PAGE_WIDTH = 210.mm
  GAP = 0.5.cm
  HEADER_INDENT = 20.mm
  HEADING_SIZE = 0.75.cm
  RED = 'f27875'
  SUBHEADING_SIZE = 0.4.cm
  MATERIALS_Y      = 191.mm
  MATERIALS_H      = 30.mm
  MATERIALS_LEFT_X = 48.mm
  MATERIALS_TOTAL_W= 140.mm 
  def apply_defaults(pdf)
    pdf.font_families.update(
      'Shingo' => {
        normal: Rails.root.join('app/assets/fonts/shingo/ShinMGoPro-DeBold.ttf')
      }
    )
    pdf.font 'Shingo'
    pdf.fill_color SECONDARY_COLOR
  end
end
