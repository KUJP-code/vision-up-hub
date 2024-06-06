# frozen_string_literal: true

class PdfTutorial < ApplicationRecord
  include Tutorials
  has_one_attached :file

  attribute :title, :string
  attribute :section, :string

  validates :title, presence: true
  validates :section, presence: true
  validates :file, presence: true

  def full_file_path
    Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
  end
end
