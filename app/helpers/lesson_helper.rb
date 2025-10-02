# frozen_string_literal: true

module LessonHelper
  def events_visible_range_for(event_date, past: 1.month, future: 3.months)
    return nil unless event_date

    start  = (event_date - future).to_date
    finish = (event_date + past).to_date
    "#{I18n.l(start)} – #{I18n.l(finish)}"
  end

  def level_icon_path(lesson)
    level = lesson.short_level.downcase.tr(' ', '_')
    "levels/#{level}.svg"
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

  def can_remove_resource?(user, lesson, blob)
    return true if user.is?('Admin')
    return false unless user.is?('Writer')

    # either assigned editor or creator
    owner_match = [lesson.assigned_editor_id, lesson.creator_id].compact.include?(user.id)

    # or if they uploaded the blob
    uploaded_by = blob.metadata['uploaded_by_id'] == user.id

    owner_match || uploaded_by
  end
end
