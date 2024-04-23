# frozen_string_literal: true

class PDFTutorial < ApplicationRecord
  include Tutorials

  # Specific attributes for pdf resource
  attribute :title, :string
  attribute :file_path, :string
  attribute :section, :string

  # Validations
  validates :title, presence: true
  validates :file_path, presence: true
  validates :section, presence: true
end
