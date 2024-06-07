# frozen_string_literal: true

module Pdfable
  extend ActiveSupport::Concern

  UPLOADED_GUIDES = %w[EnglishClass
                       Exercise
                       EveningClass
                       KindyPhonic
                       SpecialLesson
                       StandShowSpeak].freeze

  included do
    require 'prawn/measurement_extensions'
    include PdfDefaults

    has_one_attached :guide do |g|
      g.variant :thumb, resize_to_limit: [300, 300],
                        convert: :avif, preprocessed: true
    end

    def attach_guide
      # We're just uploading them for now
      return if UPLOADED_GUIDES.include?(type)

      timestamp = Time.zone.now.strftime('%Y%M%d%H%m%s')
      filename = "#{timestamp}_#{title.parameterize(separator: '_')}_guide.pdf"
      pdf_io = guide_tempfile
      pdf_blob = ActiveStorage::Blob.create_and_upload!(
        io: pdf_io, filename:, content_type: 'application/pdf'
      )
      guide.attach(pdf_blob)
      pdf_io
    end

    private

    def guide_tempfile
      Tempfile.create do |f|
        generate_guide.render_file(f)
        File.open(f)
      end
    end
  end
end
