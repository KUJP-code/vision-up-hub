# frozen_string_literal: true

class Notification
  include StoreModel::Model

  attribute :link, :string
  attribute :read, :boolean, default: false
  attribute :text, :string

  validates :link, :text, presence: true
  validate :valid_uri

  private

  def valid_uri
    return if URI.parse(link).instance_of?(URI::HTTPS)

    errors.add(:link, "#{link} is not a valid URL")
  end
end
