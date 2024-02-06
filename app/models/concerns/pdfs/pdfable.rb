# frozen_string_literal: true

module Pdfable
  extend ActiveSupport::Concern

  included do
    require 'prawn/measurement_extensions'

    def attach_guide
      filename = "#{Time.zone.now}_#{title.parameterize(separator: '_')}_guide.pdf"
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
