# frozen_string_literal: true

class NotifyUserJob < ApplicationJob
  queue_as :notifications

  def perform(user_id:, text:, link:)
    notification = Notification.new(text:, link:)
    user = User.find(user_id)
    user.notify(notification)
  end
end
