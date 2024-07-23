# frozen_string_literal: true

class VideoTutorial < ApplicationRecord
  YOUTUBE_HOSTS = %w[youtube.com youtu.be].freeze
  YOUTUBE_EMBED_PATH = 'https://www.youtube.com/embed/'

  VIMEO_HOSTS = %w[vimeo.com].freeze
  VIMEO_EMBED_PATH = 'https://player.vimeo.com/video/'

  VALID_HOSTS = YOUTUBE_HOSTS + VIMEO_HOSTS

  belongs_to :tutorial_category

  before_validation :convert_video_link, unless: :embeddable_link?

  validates :title, :video_path, presence: true
  validate :allowed_host?

  def allowed_host?
    return true if VALID_HOSTS.any? { |host| video_path.include?(host) }

    disallowed_host_error
  end

  private

  def convert_video_link
    return disallowed_host_error unless allowed_host?

    if YOUTUBE_HOSTS.any? { |host| video_path.include?(host) }
      self.video_path = convert_youtube_link
    elsif VIMEO_HOSTS.any? { |host| video_path.include?(host) }
      self.video_path = "#{VIMEO_EMBED_PATH}#{video_path.split('/').last}"
    else
      errors.add(:video_path, 'missing conversion for given host')
    end
  end

  def convert_youtube_link
    video_id = if video_path.include?('youtu.be')
                 video_path.split('/').last
               else
                 CGI.parse(URI.parse(video_path).query)['v'].first
               end
    "#{YOUTUBE_EMBED_PATH}#{video_id}"
  rescue StandardError
    errors.add(:video_path, "#{video_path} is not a valid URL")
  end

  def disallowed_host_error
    errors.add(:video_path,
               "#{video_path} does not include #{VALID_HOSTS.join(' or ')}" )
  end

  def embeddable_link?
    video_path.include?(YOUTUBE_EMBED_PATH) ||
      video_path.include?(VIMEO_EMBED_PATH)
  end
end
