# frozen_string_literal: true

class PdfTutorial < ApplicationRecord
  def self.policy_class
    TutorialPolicy
  end

  has_one_attached :file
  belongs_to :tutorial_category

  validates :title, :file, presence: true
  validate :file_presence
  validate :file_type

  VALID_FILETYPES = [
    'application/pdf',
    'application/vnd.ms-excel', # XLS
    'application/vnd.ms-powerpoint', # PPT
    'application/vnd.openxmlformats-officedocument.presentationml.presentation', # PPTX
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', # XLSX
    'image/jpeg',
    'image/jpg',
    'image/png'
  ].freeze

  def type
    'PDF'
  end

  private

  def file_presence
    errors.add(:file, 'must be attached') unless file.attached?
  end

  def file_type
    return unless file.attached?
    return if VALID_FILETYPES.include?(file.blob.content_type)

    errors.add(:file, 'must be a PDF, PPT, PPTX, XLS, XLSX, JPG, or PNG')
  end
end
