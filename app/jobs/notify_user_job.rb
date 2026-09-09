# frozen_string_literal: true

class NotifyUserJob < ApplicationJob
  INTERNAL_HOSTS = %w[vision-up.app www.vision-up.app hub.kids-up.app].freeze

  queue_as :notifications

  def perform(user_id:, text:, link:)
    sanitized_link = sanitize_link(link)
    notification = Notification.new(text: text, link: sanitized_link)

    user = User.find(user_id)
    user.notify(notification)
  end

  private

  def sanitize_link(link)
    return link if link.blank?

    normalized = link.strip
    return normalized if normalized.start_with?('/') && !normalized.start_with?('//')

    normalized = "https:#{normalized}" if normalized.start_with?('//')
    uri = URI.parse(normalized)
    uri = URI.parse("https://#{normalized}") if uri.scheme.nil?
    return normalized unless uri.is_a?(URI::HTTP)
    return uri.to_s unless INTERNAL_HOSTS.include?(uri.host.to_s.downcase)

    path = uri.request_uri
    path += "##{uri.fragment}" if uri.fragment
    path
  rescue URI::InvalidURIError
    link # fallback to original if parsing fails
  end
end
