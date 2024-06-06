# frozen_string_literal: true

module PdfImageable
  extend ActiveSupport::Concern

  included do
    validate :valid_pdf_image_filetype?

    has_one_attached :pdf_image

    private

    def add_image(pdf)
      return unless pdf_image.attached?

      pdf_image.blob.open do |file|
        pdf.image(
          file.path,
          position: 120.mm,
          vposition: 15.mm,
          width: 198,
          height: 130
        )
      end
    end

    def valid_pdf_image_filetype?
      return true if pdf_image.blank?

      extension = pdf_image.content_type.split('/').last
      return true if %w[png jpg jpeg].include?(extension)

      image.purge
      errors.add(attr, 'must be a PNG, JPG, or JPEG')
      false
    end
  end
end
