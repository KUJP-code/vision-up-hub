# frozen_string_literal: true

class TutorialCategory < ApplicationRecord
  has_one_attached :svg

  has_many :pdf_tutorials, dependent: :restrict_with_error
  has_many :faq_tutorials, dependent: :restrict_with_error
  has_many :video_tutorials, dependent: :restrict_with_error

  validates :title, :svg, presence: true
  validates :title, uniqueness: true
  validate :svg_presence
  validate :svg_type

  VALID_FILETYPES = ['image/svg+xml'].freeze
  TUTORIAL_TYPES = %i[FAQ PDF Video].freeze

  private

  def svg_presence
    errors.add(:svg, 'must be attached') unless svg.attached?
  end

  def svg_type
    return unless svg.attached?
    return if VALID_FILETYPES.include?(svg.blob.content_type)

    errors.add(:svg, 'must be a SVG')
  end
end
