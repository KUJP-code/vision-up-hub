# frozen_string_literal: true

module CertificatePdf
  extend ActiveSupport::Concern
  require 'prawn/measurement_extensions'

  included do
    def pdf(level:, name:, date_changed:)
      pdf = create_pdf_object
      add_certificate_background(pdf, level)
      add_certificate_text(pdf, name, date_changed)
      pdf.render
    end
  end

  private

  def create_pdf_object
    Prawn::Document.new(page_size: 'A4', margin: 36).tap do |pdf|
      pdf.font_families.update(
        'NoToSansJP' => {
          normal: Rails.root.join('app/assets/fonts/NotoSansJP-Medium.ttf')
        }
      )
      pdf.font 'NoToSansJP'
    end
  end

  def background_file_for(level)
    Rails.root.join('app', 'assets', 'pdf_backgrounds', "#{level}_certificate.png")
  end

  def add_certificate_background(pdf, level)
    bg_file = background_file_for(level)
    if File.exist?(bg_file)
      pdf.image bg_file.to_s,
                at: [0, pdf.bounds.top],
                width: pdf.bounds.width,
                height: pdf.bounds.height
    else
      Rails.logger.warn "Certificate background file not found: #{bg_file}"
    end
  end

  def add_certificate_text(pdf, name, date_changed)
    pdf.fill_color '000000'

    pdf.text_box "Name: #{name}",
                 at: [36, pdf.bounds.top - 100],
                 width: pdf.bounds.width - 72,
                 size: 18,
                 style: :bold,
                 align: :center

    pdf.text_box "Date Changed: #{date_changed.strftime('%B %d, %Y')}",
                 at: [36, pdf.bounds.top - 140],
                 width: pdf.bounds.width - 72,
                 size: 14,
                 align: :center
  end
end
