# frozen_string_literal: true

module PdfImageValidatable
  extend ActiveSupport::Concern
  VALID_IMAGE_TYPES = ['image/png', 'image/jpeg'].freeze

  included do
    validate :image_filetypes

    private

    def image_filetypes
      self.class::PDF_IMAGES.each do |attr|
        attached = send(attr)
        next if attached.blank?

        if attached.is_a?(ActiveStorage::Attached::Many)
          validate_many_image_filetypes(attr, attached)
        elsif VALID_IMAGE_TYPES.exclude?(attached.content_type)
          attached.purge
          errors.add(attr, 'must be a PNG, JPG, or JPEG')
        end
      end
    end

    def validate_many_image_filetypes(attr, attached)
      return if attached.attachments.all? { |a| VALID_IMAGE_TYPES.include?(a.blob&.content_type) }

      errors.add(attr, 'must all be PNG, JPG, or JPEG')
    end
  end
end
