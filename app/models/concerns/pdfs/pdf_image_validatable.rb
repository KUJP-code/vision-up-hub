# frozen_string_literal: true

module PdfImageValidatable
  extend ActiveSupport::Concern
  VALID_IMAGE_TYPES = ['image/png', 'image/jpeg'].freeze

  included do
    validate :image_filetypes

    private

    def image_filetypes
      self.class::PDF_IMAGES.each do |attr|
        next if send(attr).blank?
        next if VALID_IMAGE_TYPES.include?(send(attr).content_type)

        send(attr).purge
        errors.add(attr, 'must be a PNG, JPG, or JPEG')
      end
    end
  end
end
