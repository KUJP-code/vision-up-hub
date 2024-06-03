# frozen_string_literal: true

module LessonHelper
  def level_icon_path(lesson)
    "levels/#{lesson.short_level.downcase}.svg"
  end

  def status_color(lesson)
    case lesson.status
    when 'proposed', 'changes_needed'
      'bg-main'
    when 'accepted'
      'bg-success'
    when 'rejected'
      'bg-danger'
    end
  end

  def stringify_links(links)
    if links.instance_of?(Hash)
      links.map { |k, v| "#{k}:#{v}" }.join("\n")
    else
      links
    end
  end

  def type_icon_path(lesson)
    type = case lesson.type
           when 'DailyActivity', 'Exercise'
             lesson.subtype
           else
             lesson.type.underscore
           end

    "lesson_types/#{type}.svg"
  end

  def with_subtype(lesson)
    return lesson.title unless lesson.class::ATTRIBUTES.include?(:subtype)

    "#{lesson.title} (#{lesson.subtype.humanize})"
  end
end
