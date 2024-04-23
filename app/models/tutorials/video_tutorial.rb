# frozen_string_literal: true

class VideoTutorial < ApplicationRecord
  include Tutorials
  # Specific attributes for pdf resource
  attribute :title, :string
  attribute :video_path, :string
  attribute :section, :string

  # Validations
  validates :title, presence: true
  validates :video_path, presence: true
  validates :section, presence: true
end
