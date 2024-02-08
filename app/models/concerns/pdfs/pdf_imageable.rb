# frozen_string_literal: true

module PdfImageable
  extend ActiveSupport::Concern

  included do
    validate :pdf_image_filetypes

    private

    def pdf_image_filetypes
      self.class::PDF_IMAGEABLE_ATTRIBUTES.each do |attr|
        next if send(attr).blank? || valid_filetype?(attr)
      end
    end

    def valid_filetype?(attr)
      image = send(attr)
      extension = image.content_type.split('/').last
      return true if %w[png jpg jpeg].include?(extension)

      image.purge
      errors.add(attr, 'must be a PNG, JPG, or JPEG')
      false
    end
  end
end
