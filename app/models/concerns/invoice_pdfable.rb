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
    # 1. Big banner with '領収書' in white text on blue background
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      pdf.fill_color '2864f0'      # Blue background
      pdf.fill_rectangle([0, pdf.cursor], pdf.bounds.width, 50)
      pdf.fill_color 'FFFFFF'      # White text
      pdf.text_box(
        '領収書',
        size: 25,
        at: [0, pdf.cursor - 13],  # Nudging the text to be vertically centered
        width: pdf.bounds.width,
        align: :center
      )
      # Reset fill color to black for normal text afterwards
      pdf.fill_color '000000'
      pdf.move_down 50
    end

    pdf.move_down 40

    # 2. Split the header into left and right columns
    #    We'll do two bounding boxes side-by-side.

    # Left side bounding box
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width / 2) do
      # 2a. Recipient info
      pdf.text '〇〇 〇〇様 御中', size: 20, align: :center
      pdf.move_down 20

      # 2b. Amount portion
      #     We’ll make a mini "blue header" for 金額（税込）
      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width, align: :center) do
        pdf.line_width = 1
        pdf.stroke_color '000000'
        pdf.stroke_bounds
        pdf.fill_color '2864f0'
        pdf.fill_rectangle([0, pdf.cursor], pdf.bounds.width, 20)
        pdf.fill_color 'FFFFFF'
        pdf.text_box(
          '金額（税込）',
          size: 12,
          at: [5, pdf.cursor - 5],
          width: pdf.bounds.width,
          align: :center
        )
        pdf.fill_color '000000'
      end

      pdf.move_down 30

      # 2c. Big bold amount
      pdf.text '¥0', size: 30, align: :center
      pdf.move_down 10

      # 2d. “〇月分のお月謝として” etc.
      pdf.text '〇月分のお月謝として', size: 10
      pdf.text '但し', size: 10
      pdf.text '上記正に領収いたしました。', size: 10
    end

    # Right side bounding box
    pdf.bounding_box([pdf.bounds.width / 2, pdf.cursor], width: pdf.bounds.width / 2) do
      # 2e. 発行日 (issue date)
      pdf.move_down 5
      pdf.text "発行日: #{created_at.strftime('%Y年%m月%d日')}", size: 10, align: :left

      pdf.move_down 10
      # 2f. 登録番号
      pdf.text '登録番号: T7011801037173', size: 10, align: :left

      pdf.move_down 10
      # 2g. Company info
      pdf.text '株式会社Kids-UP', size: 10
      pdf.text '〒120-0034', size: 10
      pdf.text "住所: 東京都足立区千住1-4-1\n東京芸術センター11階", size: 10
      pdf.text '電話: 03-3870-0099', size: 10

      pdf.move_down 10

      # If you need actual space below for stamps, you could do something like:
      # (One approach is to create an empty row with space for stamps)
      # But this is optional, depending on how you want to format it.
      stamp_data = [
        ['', '', ''] # Just empty cells for now
      ]
      pdf.table stamp_data, width: pdf.bounds.width / 2, cell_style: { height: 30 } do |t|
        t.cells.borders = %i[left right bottom]
      end
    end
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
