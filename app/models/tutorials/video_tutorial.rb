# frozen_string_literal: true

class VideoTutorial < ApplicationRecord
  include VideoEmbeddable

  def self.policy_class
    TutorialPolicy
  end

  belongs_to :tutorial_category

  validates :title, :video_path, presence: true

  def type
    'Video'
  end
end
