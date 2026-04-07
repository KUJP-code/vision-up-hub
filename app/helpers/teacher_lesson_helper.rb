# frozen_string_literal: true

module TeacherLessonHelper
  Card = Struct.new(:kind, :type, :subtype, keyword_init: true)

  def lesson_type_heading(lesson)
    heading = case lesson.type
              when 'KindyPhonic', 'PhonicsClass'
                'phonics'
              when 'EveningClass'
                lesson.title
              when 'SpecialLesson', 'SeasonalActivity', 'EventActivity', 'PartyActivity'
                lesson.title
              else
                lesson.type.underscore
              end

    t("lessons.#{heading}")
  end

  def lesson_type_order(level)
    {
      'kindy' => %w[arrival sensory_play get_up_and_go snack SpecialLesson DailyActivity
                    Exercise KindyPhonic story_and_reading friendship_time EnglishClass StandShowSpeak bus_time],
      'elementary' => %w[arrival brush_up snack SpecialLesson DailyActivity
                         Exercise daily_gathering PhonicsClass EnglishClass
                         StandShowSpeak bus_time],
      'keep_up' => %w[snack book_activity EveningClass
                      lesson_review],
      'specialist' => %w[EveningClass]
    }[level]
  end

  def teacher_lesson_cards(level, day_lessons)
    lesson_types = day_lessons.pluck(:type).uniq

    cards = lesson_type_order(level).flat_map do |type|
      if type == 'EveningClass'
        evening_class_cards(level, day_lessons)
      elsif Lesson::TYPES.include?(type)
        next [] if lesson_types.exclude?(type)

        [Card.new(kind: :lesson, type:)]
      else
        [Card.new(kind: :resource, type:)]
      end
    end

    return cards if Flipper.enabled?(:afterschool_extras, current_user)

    cards.reject do |card|
      card.kind == :resource && CategoryResource::AFTERSCHOOL_EXTRAS.include?(card.type)
    end
  end

  def teacher_lesson_card_title(type, level:, subtype: nil)
    return t("lessons.subtypes.#{subtype}") if type == 'EveningClass' && subtype.present?

    if type == 'EveningClass'
      t("lessons.#{level == 'specialist' ? 'research_study' : 'topic_study'}")
    elsif Lesson::TYPES.include?(type)
      key = type.include?('Phonic') ? 'phonics' : type.underscore
      t("lessons.#{key}")
    else
      t("category_resources.#{type}")
    end
  end

  def lesson_image_tag(lesson, type, **)
    src = lesson.cover_image.attached? ? url_for(lesson.cover_image) : asset_path("levels/#{type.downcase}.svg")
    image_tag(src, **)
  end

  def tutorial_image_tag(category, **)
    src = category.cover_image.attached? ? url_for(category.cover_image) : asset_path('tutorials.svg')
    image_tag(src, **)
  end

  def lesson_level_heading(lesson)
    if lesson.class::ATTRIBUTES.include?(:subtype) && lesson.subtype.present?
      t("lessons.subtypes.#{lesson.subtype}")
    else
      t("levels.#{lesson.short_level.downcase.tr(' ', '_')}").upcase
    end
  end

  def lesson_details_heading(lesson)
    case lesson.type
    when 'EveningClass'
      lesson.goal
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

  private

  def evening_class_cards(level, day_lessons)
    subtypes = day_lessons.where(type: 'EveningClass')
                          .where.not(subtype: nil)
                          .map(&:subtype)
                          .uniq

    EveningClass.subtypes_for(level).filter_map do |subtype|
      next unless subtypes.include?(subtype)

      Card.new(kind: :lesson, type: 'EveningClass', subtype:)
    end
  end
end
