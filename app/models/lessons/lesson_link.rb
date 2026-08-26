# frozen_string_literal: true

class LessonLink < ApplicationRecord
  HUB_HOSTS = %w[
    hub.kids-up.app
    vision-up.app
    vision-up.hub
    vision.hub
  ].freeze

  belongs_to :lesson

  enum kind: { resource: 0, video: 1 }

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
    if u.start_with?('/')
      self.url = u
      self.kind = :resource
      return
    end

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

    if HUB_HOSTS.include?(host.downcase)
      self.url = relative_url(uri)
      self.kind = :resource
      return
    end

    if host.match?(/(youtube\.com|youtu\.be|vimeo\.com)/i)
      self.kind = :video
      # VideoEmbeddable will convert/validate
    else
      self.kind = :resource

      if host == 'docs.google.com'
        self.url = url
                   .gsub(%r{/edit(\?.*)?$}, '/preview')
                   .gsub(%r{/view(\?.*)?$}, '/preview')
      end
    end
  rescue URI::InvalidURIError
    errors.add(:url, 'is not a valid URL')
  end

  def relative_url(uri)
    path = uri.path.presence || '/'
    path += "?#{uri.query}" if uri.query.present?
    path += "##{uri.fragment}" if uri.fragment.present?
    path
  end
end
