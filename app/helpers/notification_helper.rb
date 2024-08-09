# frozen_string_literal: true

module NotificationHelper
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
