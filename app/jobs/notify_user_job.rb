# frozen_string_literal: true

class NotifyUserJob < ApplicationJob
  queue_as :notifications

  def perform(user_id:, text:, link:)
    sanitized_link = sanitize_link(link)
    notification = Notification.new(text: text, link: sanitized_link)

    user = User.find(user_id)
    user.notify(notification)
  end

  private

  def sanitize_link(link)
    uri = URI.parse(link)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS) ? uri.request_uri : link
  rescue URI::InvalidURIError
    link # fallback to original if parsing fails
  end
end
