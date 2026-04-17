# frozen_string_literal: true

class TeacherTool < ApplicationRecord
  belongs_to :organisation
  has_one_attached :cover_image

  enum :kind, { video: 0, external: 1 }, default: :video

  before_validation :clear_video_fields_for_external_tools, if: :external?

  validates :title, presence: true
  validates :title, uniqueness: { scope: :organisation_id }
  validates :url, presence: true, if: :external?
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  validate :sanitize_video_paths, if: :video?
  validate :video_paths_present, if: :video?

  def effective_embed_url
    random_embed_url.presence || embed_url.presence || url
  end

  def video_path
    video_paths_list.first || embed_url
  end

  def video_path=(value)
    self.video_paths = Array(value).compact_blank
    self.embed_url = self.video_paths.first
  end

  def video_paths_list
    Array(video_paths).compact_blank
  end

  def random_embed_url
    video_paths_list.sample
  end

  private

  def sanitize_video_paths
    raw_paths = video_paths_list
    raw_paths = [embed_url] if raw_paths.empty? && embed_url.present?
    return if raw_paths.empty?

    normalized_paths = raw_paths.map { |value| normalize_video_url(value) }
    self.video_paths = normalized_paths
    self.embed_url = normalized_paths.first
  rescue URI::InvalidURIError
    errors.add(:video_paths, "#{raw_paths.find(&:present?)} is not a valid URL")
  rescue ArgumentError
    errors.add(:video_paths, "#{raw_paths.find(&:present?)} is not supported")
  end

  def video_paths_present
    return if video_paths_list.any? || embed_url.present?

    errors.add(:video_paths, "can't be blank")
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

  def clear_video_fields_for_external_tools
    self.video_paths = []
    self.embed_url = nil
  end
end
