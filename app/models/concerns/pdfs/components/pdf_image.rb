# frozen_string_literal: true

module PdfImage
  class PdfImageFactory
    include PdfDefaults

    def initialize(pdf:, x_pos:, width:)
      @pdf = pdf
      @x_pos = x_pos
      @width = width
    end

    def add_image(image:, y_pos:, height:)
      return unless image.attached?

      @pdf.bounding_box([@x_pos, y_pos], width: @width, height:) do
        image.blob.open do |file|
          @pdf.image(file.path, fit: [@width, height])
        end
      end
    end
  end
end
