# frozen_string_literal: true

module VideoEmbeddable
  extend ActiveSupport::Concern

  YOUTUBE_HOSTS = %w[youtube.com www.youtube.com youtu.be www.youtu.be].freeze
  YOUTUBE_EMBED_PATH = 'https://www.youtube.com/embed/'

  VIMEO_HOSTS = %w[vimeo.com www.vimeo.com player.vimeo.com www.player.vimeo.com].freeze
  VIMEO_EMBED_PATH = 'https://player.vimeo.com/video/'

  VALID_HOSTS = (YOUTUBE_HOSTS + VIMEO_HOSTS).freeze

  included do
    before_validation :convert_video_link, unless: :embeddable_link?
    validate :allowed_host?
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

  def allowed_host?
    return true if VALID_HOSTS.include?(URI.parse(video_path).host)

    disallowed_host_error
  rescue URI::InvalidURIError
    invalid_uri_error
  end

  def convert_youtube_link
    video_id =
      if video_path.include?('youtu.be')
        video_path.split('/').last
      else
        CGI.parse(URI.parse(video_path).query)['v'].first
      end

    "#{YOUTUBE_EMBED_PATH}#{video_id}"
  rescue URI::InvalidURIError, NoMethodError
    invalid_uri_error
  end

  def embeddable_link?
    video_path&.include?(YOUTUBE_EMBED_PATH) ||
      video_path&.include?(VIMEO_EMBED_PATH)
  end

  def disallowed_host_error
    errors.add(:video_path, "#{video_path} does not include #{VALID_HOSTS.join(' or ')}")
  end

  def invalid_uri_error
    errors.add(:video_path, "#{video_path} is not a valid URL")
  end
end
