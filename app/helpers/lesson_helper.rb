# frozen_string_literal: true

module LessonHelper
  def stringify_links(links)
    links.map { |k, v| "#{k}:#{v}" }.join("\n")
  end
end
