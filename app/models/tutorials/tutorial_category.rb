# frozen_string_literal: true

class TutorialCategory < ApplicationRecord
  ITEM_KINDS = %w[link video faq].freeze
  ALLOWED_FILETYPES = [
    'application/pdf', 'application/vnd.ms-excel', 'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'image/jpeg', 'image/jpg', 'image/png'
  ].freeze

  belongs_to :tutorial_section, optional: true
  has_many :organisation_tutorial_categories, dependent: :destroy, inverse_of: :tutorial_category
  has_many :organisations, through: :organisation_tutorial_categories
  has_one_attached :cover_image
  has_many_attached :files

  attr_accessor :remove_file_ids

  validates :title, presence: true
  validates :title, uniqueness: true
  validate :valid_items
  validate :file_types
  after_save :purge_removed_files

  accepts_nested_attributes_for :organisation_tutorial_categories,
                                allow_destroy: true,
                                reject_if: proc { |a| a['organisation_id'].blank? }

  def self.embed_url(url)
    return url if embedded_url?(url)

    uri = URI.parse(url)
    return youtube_embed_url(uri) if VideoEmbeddable::YOUTUBE_HOSTS.include?(uri.host)

    vimeo_embed_url(uri) if VideoEmbeddable::VIMEO_HOSTS.include?(uri.host)
  rescue URI::InvalidURIError
    nil
  end

  def self.embedded_url?(url)
    url&.start_with?(VideoEmbeddable::YOUTUBE_EMBED_PATH, VideoEmbeddable::VIMEO_EMBED_PATH)
  end

  def self.youtube_embed_url(uri)
    video_id = uri.host.include?('youtu.be') ? uri.path.split('/').last : CGI.parse(uri.query.to_s)['v']&.first
    "#{VideoEmbeddable::YOUTUBE_EMBED_PATH}#{video_id}"
  end

  def self.vimeo_embed_url(uri)
    "#{VideoEmbeddable::VIMEO_EMBED_PATH}#{uri.path.split('/').last}"
  end

  def items_attributes=(attributes)
    self.items = attributes.values.filter_map do |item|
      next if ActiveModel::Type::Boolean.new.cast(item['_destroy'])

      item.slice('kind', 'title', 'url', 'body').compact_blank
    end
  end

  private

  def valid_items
    items.each_with_index do |item, index|
      kind = item['kind']
      errors.add(:items, "item #{index + 1} has an invalid type") unless ITEM_KINDS.include?(kind)
      errors.add(:items, "item #{index + 1} needs a title") if item['title'].blank?
      validate_item_content(item, index)
    end
  end

  def validate_item_content(item, index)
    if %w[link video].include?(item['kind']) && item['url'].blank?
      errors.add(:items, "item #{index + 1} needs a URL")
    elsif item['kind'] == 'faq' && item['body'].blank?
      errors.add(:items, "item #{index + 1} needs an answer")
    end
    validate_item_url(item, index)
  end

  def validate_item_url(item, index)
    return unless %w[link video].include?(item['kind']) && item['url'].present?

    uri = URI.parse(item['url'])
    errors.add(:items, "item #{index + 1} needs an HTTP URL") unless valid_http_url?(uri)
    validate_video_url(item, index)
  rescue URI::InvalidURIError
    errors.add(:items, "item #{index + 1} has an invalid URL")
  end

  def validate_video_url(item, index)
    return unless item['kind'] == 'video' && self.class.embed_url(item['url']).nil?

    errors.add(:items, "item #{index + 1} must use YouTube or Vimeo")
  end

  def valid_http_url?(uri)
    %w[http https].include?(uri.scheme) && uri.host.present?
  end

  def file_types
    files.each do |file|
      next if ALLOWED_FILETYPES.include?(file.blob.content_type)

      errors.add(:files, 'must be PDF, PPT, PPTX, XLS, XLSX, JPG, or PNG')
    end
  end

  def purge_removed_files
    files.attachments.where(id: Array(remove_file_ids).compact_blank).find_each(&:purge)
  end
end
