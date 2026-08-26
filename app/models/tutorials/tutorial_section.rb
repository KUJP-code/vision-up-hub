# frozen_string_literal: true

class TutorialSection < ApplicationRecord
  has_many :tutorial_categories, dependent: :nullify
  has_one_attached :cover_image

  validates :title, presence: true, uniqueness: true
  validates :position, numericality: { only_integer: true }

  default_scope { order(:position, :title) }
end
