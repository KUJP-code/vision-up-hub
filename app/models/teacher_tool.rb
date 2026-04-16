# frozen_string_literal: true

class TeacherTool < ApplicationRecord
  belongs_to :organisation
  has_one_attached :cover_image

  enum :kind, { video: 0, external: 1 }, default: :video

  validates :title, presence: true
  validates :title, uniqueness: { scope: :organisation_id }
  validates :embed_url, presence: true, if: :video?
  validates :url, presence: true, if: :external?
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  validate :sanitize_video_path, if: :video?

  def effective_embed_url
    embed_url.presence || url
  end

  def video_path
    embed_url
  end

  def video_path=(value)
    self.embed_url = value
  end

  private

  def sanitize_video_path
    return if embed_url.blank?

    self.embed_url = normalize_video_url(embed_url)
  rescue URI::InvalidURIError
    errors.add(:video_path, "#{embed_url} is not a valid URL")
  rescue ArgumentError
    errors.add(:video_path, "#{embed_url} is not supported")
  end

  def normalize_video_url(value)
    uri = URI.parse(value)
    host = uri.host

    return value if value.include?(VideoEmbeddable::YOUTUBE_EMBED_PATH) ||
                    value.include?(VideoEmbeddable::VIMEO_EMBED_PATH)

    if VideoEmbeddable::YOUTUBE_HOSTS.include?(host)
      video_id = if value.include?('youtu.be')
                   value.split('/').last
                 else
                   CGI.parse(uri.query.to_s)['v'].first
                 end
      raise ArgumentError if video_id.blank?

      "#{VideoEmbeddable::YOUTUBE_EMBED_PATH}#{video_id}"
    elsif VideoEmbeddable::VIMEO_HOSTS.include?(host)
      "#{VideoEmbeddable::VIMEO_EMBED_PATH}#{value.split('/').last}"
    else
      raise ArgumentError
    end
  end
end
