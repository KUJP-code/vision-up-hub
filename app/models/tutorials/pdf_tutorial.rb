# frozen_string_literal: true

class PdfTutorial < ApplicationRecord
  has_one_attached :file
  belongs_to :tutorial_category

  validates :title, :file, presence: true
  validate :file_presence
  validate :file_type

  # These are the file types requested from luis for this section
  ACCEPTABLE_FILE_TYPES = [
    'application/pdf', # PDF
    'application/vnd.ms-powerpoint', # PPT
    'application/vnd.openxmlformats-officedocument.presentationml.presentation', # PPTX
    'application/vnd.ms-excel', # XLS
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', # XLSX
    'image/jpeg', # JPG
    'image/png' # PNG
  ].freeze

  private

  def file_presence
    errors.add(:file, 'must be attached') unless file.attached?
  end

  def file_type
    return unless file.attached?

    return if ACCEPTABLE_FILE_TYPES.include?(file.blob.content_type)

    errors.add(:file, 'must be a PDF, PPT, PPTX, XLS, XLSX, JPG, or PNG')
  end
end
