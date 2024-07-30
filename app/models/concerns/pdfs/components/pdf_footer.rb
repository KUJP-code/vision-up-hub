# frozen_string_literal: true

module PdfFooter
  def draw_footer(pdf:, level:)
    pdf.bounding_box([140.mm, 7.mm], width: 66.mm, height: 10.mm) do
      pdf.text level, color: 'FFFFFF', align: :right
    end
  end
end
