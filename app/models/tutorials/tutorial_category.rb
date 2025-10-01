# frozen_string_literal: true

class TutorialCategory < ApplicationRecord
  has_many :pdf_tutorials, dependent: :restrict_with_error
  has_many :faq_tutorials, dependent: :restrict_with_error
  has_many :video_tutorials, dependent: :restrict_with_error
  has_many :organisation_tutorial_categories, dependent: :destroy, inverse_of: :tutorial_category
  has_many :organisations, through: :organisation_tutorial_categories
  has_one_attached :cover_image

  validates :title, presence: true
  validates :title, uniqueness: true

  TUTORIAL_TYPES = %i[FAQ PDF Video].freeze

  accepts_nested_attributes_for :organisation_tutorial_categories,
                                allow_destroy: true,
                                reject_if: proc { |a| a['organisation_id'].blank? }
end
