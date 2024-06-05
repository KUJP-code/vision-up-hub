# frozen_string_literal: true

module PdfUploadable
  extend ActiveSupport::Concern

  included do
    validate :guide_is_pdf?
  end

  private

  def guide_is_pdf?
    return true unless guide.attached?
    return true if guide.content_type == 'application/pdf'

    errors.add(:guide, 'must be a PDF')
  end
end
