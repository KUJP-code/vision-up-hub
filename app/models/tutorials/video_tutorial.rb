# frozen_string_literal: true

class VideoTutorial < ApplicationRecord
  include TutorialCategories

  validates :title, presence: true
  validates :video_path, presence: true
  validates :category, presence: true
end
