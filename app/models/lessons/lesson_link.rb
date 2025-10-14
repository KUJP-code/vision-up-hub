# frozen_string_literal: true

class LessonLink < ApplicationRecord
  belongs_to :lesson

  enum kind: { resource: 0, video: 1 }

  ALLOWED_RESOURCE_HOSTS = %w[
    docs.google.com
    drive.google.com
  ].freeze

  validates :url, presence: true
  before_validation :classify_and_normalize_url, prepend: true
  after_validation :sync_embed_url

  include VideoEmbeddable

  def video_path
    url
  end

  def video_path=(value)
    return if !value.is_a?(String) || value.blank?

    self.url = value
  end

  def embeddable_link?
    return true unless video?

    super
  end

  def allowed_host?
    return true unless video?

    super
  end

  private

  def sync_embed_url
    return unless video? && url.present?

    self.embed_url = if url.include?(VideoEmbeddable::YOUTUBE_EMBED_PATH) ||
                        url.include?(VideoEmbeddable::VIMEO_EMBED_PATH)
                       url
                     else
                       nil
                     end
  end

  def classify_and_normalize_url
    return if url.blank?

    u = url.strip
    begin
      parsed = URI.parse(u)
    rescue URI::InvalidURIError
      errors.add(:url, 'is not a valid URL')
      return
    end

    if parsed.scheme.nil?
      u = "https://#{u}"
    elsif !%w[http https].include?(parsed.scheme.downcase)
      errors.add(:url, 'is not a valid URL')
      return
    end

    self.url = u
    uri  = URI.parse(url)
    host = uri.host.to_s

    if host.match?(/(youtube\.com|youtu\.be|vimeo\.com)/i)
      self.kind = :video
      # VideoEmbeddable will convert/validate
    else
      self.kind = :resource

      unless ALLOWED_RESOURCE_HOSTS.include?(host)
        errors.add(:url, "host '#{host}' is not allowed")
        return
      end

      if host == 'docs.google.com'
        self.url = url
                   .gsub(%r{/edit(\?.*)?$}, '/preview')
                   .gsub(%r{/view(\?.*)?$}, '/preview')
      end
    end
  rescue URI::InvalidURIError
    errors.add(:url, 'is not a valid URL')
  end
end
