# frozen_string_literal: true

module PdfDefaults
  BORDER_RADIUS = 0.3.cm
  FONT_SIZE = 2.5.mm
  PADDING = 2.mm
  GAP = 0.5.cm
  HEADING_SIZE = 0.5.cm
  RED = 'f27875'
  SUBHEADING_SIZE = 0.4.cm

  def apply_defaults(pdf)
    pdf.font_families.update(
      'Shingo' => {
        normal: Rails.root.join('app/assets/fonts/shingo/ShinMGoPro-DeBold.ttf')
      }
    )
    pdf.font 'Shingo'
    pdf.fill_color '645780'
  end
end
