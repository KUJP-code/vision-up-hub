# frozen_string_literal: true

class Announcement < ApplicationRecord
  validates :message, :valid_from, :valid_until, presence: true
  validate :internal_link_only

  private

  def internal_link_only
    return if link.blank? || link.start_with?('/')

    errors.add(:link, 'must be an internal path (starting with "/")')
  end
end
