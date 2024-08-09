# frozen_string_literal: true

module NotificationHelper
  def notification_count
    count = current_user.notifications.count(&:unread?)
    return if count.zero?

    classes = 'absolute right-1.5 top-1.5 flex items-center justify-center ' \
              'rounded-full bg-secondary text-white text-xs w-5 h-5 truncate'

    content_tag(:div, count, class: classes )
  end

  def read_status(notification, index)
    classes = "w-3 h-3 rounded-full #{notification.read? ? 'bg-success' : 'bg-danger'}"
    dot = content_tag(:div, '', class: classes)

    if notification.read?
      dot
    else
      link_to(notification_path(index), data: { turbo_method: :patch }) { dot }
    end
  end
end
