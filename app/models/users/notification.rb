# frozen_string_literal: true

class Notification
  include StoreModel::Model

  MAX_NOTIFICATIONS = 10

  attribute :link, :string
  attribute :read, :boolean, default: false
  attribute :text, :string

  validates :text, presence: true
  validate :valid_uri

  def mark_read
    self.read = true
  end

  private

  def valid_uri
    return if URI.parse(link).instance_of?(URI::HTTPS)

    errors.add(:link, "#{link} is not a valid URL")
  end
end
