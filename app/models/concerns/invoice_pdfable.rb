# frozen_string_literal: true

module InvoicePdfable
  extend ActiveSupport::Concern
  require 'prawn/measurement_extensions'

  included do
    def pdf
      pdf = create_pdf_object
      pdf_header(pdf)
      pdf_body(pdf)
      pdf_footer(pdf)
      pdf.render
    end
  end

  private

  def create_pdf_object
    Prawn::Document.new(page_size: 'A4', margin: 36).tap do |pdf|
      pdf.font_families.update(
        'NotoSansJP' => {
          normal: Rails.root.join('app/assets/fonts/NotoSansJP-Medium.ttf')
        }
      )
      pdf.font 'NotoSansJP'
    end
  end

  def pdf_header(pdf)
    pdf.text '請求書', size: 22, align: :center
    pdf.move_down 15

    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      pdf.text "発行日: #{created_at.strftime('%Y年%m月%d日')}", size: 12, align: :right
      pdf.text "請求書番号: #{id}", size: 12, align: :right
    end

    pdf.move_down 20
    pdf.text '組織情報:', size: 14, align: :left
    pdf.move_down 5
    pdf.text "組織名: #{organisation.name}", size: 12
    pdf.text "メール: #{organisation.email}", size: 12
    pdf.text "電話番号: #{organisation.phone}", size: 12
  end

  def pdf_body(pdf)
    pdf.move_down 20
    pdf.text '請求内容', size: 14, align: :left
    pdf.move_down 10

    data = [
      ['項目', '詳細'],
      ['子供の数', number_of_kids.to_s],
      ['支払方法', payment_option],
      ['小計', yenify(subtotal)],
      ['消費税 (10%)', yenify(tax)],
      ['合計金額', yenify(total_cost)]
    ]

    pdf.table(data, header: true, row_colors: %w[FFFFFF F5F5F5], cell_style: {
                padding: [5, 10], borders: [:bottom]
              }) do |table|
      table.row(0).style(background_color: '2864f0', text_color: 'FFFFFF', size: 12)
      table.cells.style(align: :left)
      table.column(1).style(align: :right)
    end
  end

  def pdf_footer(pdf)
    pdf.move_down 20
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.text '株式会社Kids-UP', size: 10, align: :center
    pdf.text '〒120-0034 東京都足立区千住1-4-1 東京芸術センター11階', size: 10, align: :center
    pdf.text '電話: 03-3870-0099', size: 10, align: :center
    pdf.move_down 5
    pdf.text 'ありがとうございました!', size: 12, align: :center
  end

  def yenify(amount)
    "¥#{amount.to_fs(:delimited)}"
  end
end
