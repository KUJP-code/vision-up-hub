# frozen_string_literal: true

module LessonCalendarHelper
  CalendarEntry = Struct.new(:course_lesson, :lesson, :subtype, keyword_init: true)

  def calendar_date(date, course_lesson)
    date + (CourseLesson.days[course_lesson.day] - 2).days
  end

  def calendar_entries(course_lessons)
    course_lessons.flat_map { |course_lesson| calendar_entries_for(course_lesson) }
  end

  def calendar_lesson_title(lesson, subtype: nil)
    return t("lessons.subtypes.#{subtype}") if lesson.type == 'EveningClass' && subtype.present?

    case lesson.type
    when 'DailyActivity', 'Exercise'
      lesson.subtype.titleize
    when 'KindyPhonic', 'EnglishClass'
      lesson.topic.gsub(/Term \d+/, '')
    else
      lesson.title
    end
  end

  def day_column(day)
    col = { 'sunday' => 'col-start-2', 'monday' => 'col-start-3',
            'tuesday' => 'col-start-4', 'wednesday' => 'col-start-5',
            'thursday' => 'col-start-6', 'friday' => 'col-start-7',
            'saturday' => 'col-start-8' }[day]

    %w[monday wednesday friday].include?(day) ? "#{col} bg-neutral-dark" : col
  end

  def lesson_row(lesson, subtype: nil)
    if lesson&.type == 'EveningClass' && subtype.present?
      return evening_class_row(lesson, subtype)
    end

    type_key =
      case lesson&.type
      when 'KindyPhonic' then 'PhonicsClass'
      else lesson&.type.to_s
      end

    level_key =
      if lesson&.short_level == 'Specialist'
        lesson&.level.to_s
      else
        lesson&.short_level.to_s
      end

    rows_by_type = {
      'SpecialLesson' => {
        'All Levels' => 'row-start-3',
        'Kindy' => 'row-start-4',
        'Land' => 'row-start-5',
        'Sky' => 'row-start-6',
        'Galaxy' => 'row-start-7'
      },
      'DailyActivity' => {
        'Kindy' => 'row-start-9',
        'Elementary' => 'row-start-11'
      },
      'Exercise' => {
        'Kindy' => 'row-start-9',
        'Elementary' => 'row-start-10'
      },
      'PhonicsClass' => {
        'Kindy' => 'row-start-13',
        'Land' => 'row-start-[14]',
        'Sky' => 'row-start-[15]',
        'Galaxy' => 'row-start-[16]'
      },
      'EnglishClass' => {
        'Kindy' => 'row-start-[18]',
        'Land' => 'row-start-[19]',
        'Sky' => 'row-start-[20]',
        'Galaxy' => 'row-start-[21]'
      },
      'StandShowSpeak' => {
        'Kindy' => 'row-start-[23]',
        'Land' => 'row-start-[24]',
        'Sky' => 'row-start-[25]',
        'Galaxy' => 'row-start-[26]'
      },
      'ParentsReport' => {
        'All Levels' => 'row-start-[37]'
      }
    }

    row = rows_by_type.dig(type_key, level_key)

    unless row
      Rails.logger.warn(
        "lesson_row: missing map for type=#{type_key.inspect} level=#{level_key.inspect} " \
        "(lesson_id=#{lesson&.id}, title=#{lesson&.try(:title)})"
      )
      row = 'row-start-[38]'
    end

    row
  end

  def lesson_separator_rows
    {
      'DailyActivity' => 'row-start-6',
      'PhonicsClass' => 'row-start-12',
      'EnglishClass' => 'row-start-[17]',
      'StandShowSpeak' => 'row-start-[22]',
      'EveningClass' => 'row-start-[27]',
      'ParentsReport' => 'row-start-[36]'
    }
  end

  def lesson_type_rows
    {
      'SpecialLesson' => 'row-start-3 row-span-3',
      'DailyActivity' => 'row-start-9 row-span-3',
      'PhonicsClass' => 'row-start-13 row-span-4',
      'EnglishClass' => 'row-start-[18] row-span-4',
      'StandShowSpeak' => 'row-start-[23] row-span-4',
      'EveningClass' => 'row-start-[28] row-span-8',
      'ParentsReport' => 'row-start-[37] row-span-2'
    }
  end

  def calendar_level_dots(level)
    base_dot_classes = 'absolute rounded-full w-3 h-3 top-2'
    return all_levels_dot(base_dot_classes) if ['All Levels', 'Elementary'].include?(level)

    content_tag(:div, '', class: "#{base_dot_classes} right-2 #{calendar_dot_bg(level)}")
  end

  def calendar_dot_bg(level)
    { 'Kindy' => 'bg-kindy', 'Land' => 'bg-land', 'Sky' => 'bg-sky',
      'Galaxy' => 'bg-galaxy', 'Keep Up' => 'bg-keep-up',
      'Specialist' => 'bg-specialist' }[level]
  end

  def all_levels_dot(base_classes)
    content_tag(:div, '', class: "#{base_classes} right-2 bg-land") +
      content_tag(:div, '', class: "#{base_classes} right-4 bg-sky") +
      content_tag(:div, '', class: "#{base_classes} right-6 bg-galaxy")
  end

  private

  def calendar_entries_for(course_lesson)
    lesson = course_lesson.lesson
    return [CalendarEntry.new(course_lesson:, lesson:, subtype: nil)] unless lesson.type == 'EveningClass'

    if lesson.specialist_structured?
      lesson.specialist_subtypes_with_content.map do |subtype|
        CalendarEntry.new(course_lesson:, lesson:, subtype:)
      end
    elsif lesson.specialist? && EveningClass::LEGACY_SPECIALIST_SUBTYPES.include?(lesson.subtype)
      []
    else
      [CalendarEntry.new(course_lesson:, lesson:, subtype: lesson.subtype)]
    end
  end

  def evening_class_row(lesson, subtype)
    if lesson.keep_up?
      {
        'conversation_time' => 'row-start-[28]',
        'topic_study' => 'row-start-[29]',
        'special_lesson' => 'row-start-[30]'
      }.fetch(subtype.to_s, 'row-start-[38]')
    else
      {
        'literacy' => 'row-start-[31]',
        'discussion' => 'row-start-[32]',
        'project_session_1' => 'row-start-[33]',
        'project_session_2' => 'row-start-[34]',
        'special_lesson' => 'row-start-[35]'
      }.fetch(subtype.to_s, 'row-start-[38]')
    end
  end
end
