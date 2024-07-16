# frozen_string_literal: true

class PdfTutorial < ApplicationRecord
  include TutorialCategories
  has_one_attached :file
  validates :title, presence: true
  validates :category, presence: true
  validates :file, presence: true
end
