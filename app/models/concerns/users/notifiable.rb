# frozen_string_literal: true

module Notifiable
  extend ActiveSupport::Concern

  included do
    def delete_notification(index:)
      notifications.delete_at(index)
    end

    def mark_all_notifications_read
      notifications.each(&:mark_read)
    end

    def notify(*new_notifications)
      new_notifications.each { |n| notifications << n }
      prune_read_notifications
    end
  end

  private

  def prune_read_notifications
    return if notifications.size <= Notification::MAX_NOTIFICATIONS

    read_notification = notifications.index(&:read)
    return if read_notification.nil?

    notifications.delete_at(read_notification)
    prune_read_notifications
  end
end
