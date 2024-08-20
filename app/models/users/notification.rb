# frozen_string_literal: true

# These do not have their own table, they're a JSONB column on User
class Notification
  include StoreModel::Model

  MAX_NOTIFICATIONS = 9

  attribute :created_at, :datetime, default: -> { Time.zone.now }
  attribute :link, :string, default: ''
  attribute :read, :boolean, default: false
  attribute :text, :string

  validates :text, presence: true
  validate :valid_uri

  def mark_read
    self.read = true
  end

  def unread?
    !read
  end

  private

  def valid_uri
    return if link.blank? ||
              URI.parse(link).instance_of?(URI::HTTP) ||
              URI.parse(link).instance_of?(URI::HTTPS)

    errors.add(:link, "#{link} is not a valid URL")
  end
end
