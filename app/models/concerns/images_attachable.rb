# frozen_string_literal: true

module ImagesAttachable
  extend ActiveSupport::Concern

  included do
    validate :image_filetypes

    has_many_attached :images
  end

  private

  def image_filetypes
    images.each do |image|
      next if image.blob.content_type.include?('image/')

      errors.add(:images, "#{image.filename} is not a recognised image format")
    end
  end
end
