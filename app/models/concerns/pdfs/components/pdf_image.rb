# frozen_string_literal: true

module PdfImage
  class PdfImageFactory
    include PdfDefaults

    def initialize(pdf:, x_pos:, width:)
      @pdf = pdf
      @x_pos = x_pos
      @width = width
    end

    def add_image(image:, y_pos:, height:, position: :left)
      return unless image.attached?

      add_blob(blob: image.blob, y_pos:, height:, position:)
    end

    def add_blob(blob:, y_pos:, height:, position: :left)
      @pdf.bounding_box([@x_pos, y_pos], width: @width, height:) do
        blob.open do |file|
          @pdf.image(file.path, fit: [@width, height], position:)
        end
      end
    end
  end
end
