class VideoTutorial < ApplicationRecord
  belongs_to :tutorial_category

  validates :title, :video_path, presence: true
  validate :valid_video_link

  def valid_video_link
    return if video_path.blank?

    return if video_path.include?('youtube.com') || video_path.include?('youtu.be') || video_path.include?('vimeo.com')

    errors.add(:video_path, 'must be a valid YouTube or Vimeo link')
  end
end
