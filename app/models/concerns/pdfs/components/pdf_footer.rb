# frozen_string_literal: true

module PdfFooter
  def draw_footer(pdf:, level:, page_num: nil)
    if page_num
      pdf.bounding_box([95.mm, 7.mm], width: 20.mm, height: 10.mm) do
        pdf.text page_num, color: 'FFFFFF', align: :center
      end
    end
    pdf.bounding_box([140.mm, 7.mm], width: 66.mm, height: 10.mm) do
      pdf.text level, color: 'FFFFFF', align: :right
    end
  end
end
