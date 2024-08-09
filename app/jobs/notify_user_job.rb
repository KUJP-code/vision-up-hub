# frozen_string_literal: true

class NotifyUserJob < ApplicationJob
  queue_as :notifications

  def perform(user_id, text:, link:)
    notification = Notification.new(text:, link:)
    User.find(user_id).notify(notification)
  end
end
