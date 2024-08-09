# frozen_string_literal: true

module Notifiable
  extend ActiveSupport::Concern

  included do
    def delete_notification(index:)
      notifications.delete_at(index)
      prune_read_notifications
      mark_dirty_and_save
    end

    def mark_all_notifications_read
      notifications.each(&:mark_read)
      prune_read_notifications
      mark_dirty_and_save
    end

    def mark_notification_read(index:)
      notifications[index].mark_read
      prune_read_notifications
      mark_dirty_and_save
    end

    def notify(*new_notifications)
      new_notifications.each { |n| notifications.prepend(n) }
      prune_read_notifications
      mark_dirty_and_save
    end
  end

  private

  def mark_dirty_and_save
    self.notifications = notifications.map(&:as_json)
    save
  end

  def prune_read_notifications
    return if notifications.size <= Notification::MAX_NOTIFICATIONS

    read_notification = notifications.index(&:read)
    return if read_notification.nil?

    notifications.delete_at(read_notification)
    prune_read_notifications
  end
end
