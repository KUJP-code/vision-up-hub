# frozen_string_literal: true

module InvoicePdfable
  extend ActiveSupport::Concern
  require 'prawn'
  require 'prawn/measurement_extensions'
  require 'prawn/table'

  included do
    def pdf
      Rails.logger.info "Generating PDF for Invoice ##{id}"
      pdf = create_pdf_object
      pdf_header(pdf)
      pdf_invoice_details(pdf)
      pdf_footer(pdf)
      pdf.render
    end
  end

  private

  def create_pdf_object
    pdf = Prawn::Document.new
    pdf.font_families.update(
      'NotoSans' => {
        normal: Rails.root.join('app/assets/fonts/NotoSansJP-Medium.ttf')
      }
    )
    pdf.font('NotoSans')
    pdf
  end

  def pdf_header(pdf)
    pdf.text 'Invoice', size: 20, align: :center
    pdf.move_down 20

    organisation = self.organisation

    pdf.text "Issued Date: #{created_at.strftime('%Y-%m-%d')}", align: :right
    pdf.text "Invoice ID: #{id}", align: :right
    pdf.move_down 10

    pdf.text 'Organisation Details:', size: 14
    pdf.text "Name: #{organisation.name}"
    pdf.text "Email: #{organisation.email}"
    pdf.text "Phone: #{organisation.phone}"
    pdf.move_down 20
  end

  def pdf_invoice_details(pdf)
    pdf.text 'Invoice Details:', size: 14
    pdf.table(
      [
        ['Number of Kids', number_of_kids],
        ['Payment Option', payment_option],
        ['Subtotal', yenify(subtotal)],
        ['Tax', yenify(tax)],
        ['Total Cost', yenify(total_cost)]
      ],
      header: false,
      cell_style: { borders: [] }
    )
    pdf.move_down 20
  end

  def pdf_footer(pdf)
    # Footer with company information
    pdf.move_down 20
    pdf.text('Thank you for your business!', align: :center, size: 12)
    pdf.move_down 10

    # Company Info
    pdf.text('株式会社Kids-UP', align: :center, size: 10)
    pdf.text('〒120-0034', align: :center, size: 10)
    pdf.text('住所：東京都足立区千住1-4-1東京芸術センター11階', align: :center, size: 10)
    pdf.text('電話：03-3870-0099', align: :center, size: 10)
  end

  def yenify(amount)
    "¥#{amount.to_fs(:delimited)}"
  end
end
