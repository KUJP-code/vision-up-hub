# frozen_string_literal: true

module TeacherLessonHelper
  def lesson_type_heading(lesson)
    case lesson.type
    when 'KindyPhonic'
      'Phonics Class'
    when 'SpecialLesson'
      lesson.title
    else
      lesson.type.titleize
    end
  end

  def lesson_type_order(level)
    case level
    when 'kindy', 'elementary'
      %w[arrival brush_up snack SpecialLesson DailyActivity Exercise
         DailyGathering PhonicsClass KindyPhonic EnglishClass
         StandShowSpeak bus_time]
    when 'keep_up'
      %w[conversation_time snack book_activity EveningClass lesson_review]
    when 'specialist'
      %w[homework_check break_&_quiz four_skills project EveningClass]
    end
  end

  def lesson_level_heading(lesson)
    return lesson.subtype.titleize if %w[DailyActivity Exercise].include?(lesson.type)

    if lesson.short_level == 'Specialist'
      lesson.level.titleize
    else
      lesson.short_level
    end.upcase
  end

  def lesson_details_heading(lesson)
    case lesson.type
    when 'DailyActivity', 'Exercise'
      lesson.title
    when 'EnglishClass', 'KindyPhonic'
      lesson.topic
    else
      lesson.goal
    end
  end

  def lvl_border_class(level)
    lvl_classes = { 'Kindy' => 'border-kindy', 'Land' => 'border-land',
                    'Sky' => 'border-sky', 'Galaxy' => 'border-galaxy',
                    'Keep Up' => 'border-keep-up',
                    'Specialist' => 'border-specialist' }

    lvl_classes[level] || 'border-secondary'
  end

  def lvl_text_class(level)
    lvl_classes = { 'Kindy' => 'text-kindy', 'Land' => 'text-land',
                    'Sky' => 'text-sky', 'Galaxy' => 'text-galaxy',
                    'Keep Up' => 'text-keep-up',
                    'Specialist' => 'text-specialist' }

    lvl_classes[level] || 'text-secondary'
  end
end
