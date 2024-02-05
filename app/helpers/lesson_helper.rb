# frozen_string_literal: true

module LessonHelper
  def icon_path(lesson)
    "#{lesson.type.underscore}.svg"
  end

  def stringify_links(links)
    if links.instance_of?(Hash)
      links.map { |k, v| "#{k}:#{v}" }.join("\n")
    else
      links
    end
  end
end
