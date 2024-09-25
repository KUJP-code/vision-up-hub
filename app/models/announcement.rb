# frozen_string_literal: true

class Announcement < ApplicationRecord
  VALID_HOSTS = %w[www.vision-up.app vision-up.app]

  validates :message, :start_date, :finish_date, presence: true
  validate :internal_link_only
  enum :role, User::TYPES.map.with_index { |role, i| [role, i] }.to_h

  belongs_to :organisation, optional: true

  private

  def internal_link_only
    return if link.blank? || VALID_HOSTS.any?(URI.parse(link).host)

    errors.add(:link, 'can only be within the site')
  rescue URI::InvalidURIError
    errors.add(:link, "#{link} is not a valid URL")
  end
end
