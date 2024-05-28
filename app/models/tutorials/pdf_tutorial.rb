# frozen_string_literal: true

class PdfTutorial < ApplicationRecord
  include Tutorials
  attribute :title, :string
  attribute :file_path, :string
  attribute :section, :string

  validates :title, presence: true
  validates :file_path, presence: true
  validates :section, presence: true

  def full_file_path
    file_path =~ /^https?:\/\// ? file_path : "http://#{file_path}"
  end
end
