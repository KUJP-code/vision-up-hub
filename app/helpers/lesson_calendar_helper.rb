# frozen_string_literal: true

module LessonCalendarHelper
  def lesson_type_rows
    { 'DailyActivity' => 'row-span-3', 'PhonicsClass' => 'row-span-4',
      'EnglishClass' => 'row-span-4', 'StandShowSpeak' => 'row-span-3',
      'EveningClass' => 'row-span-2' }
  end

  def day_column(day)
    { 'sunday' => 'col-start-2', 'monday' => 'col-start-3', 'tuesday' => 'col-start-4',
      'wednesday' => 'col-start-5', 'thursday' => 'col-start-6', 'friday' => 'col-start-7',
      'saturday' => 'col-start-8' }[day]
  end

  def lesson_row(lesson)
    type = case lesson.type
           when 'KindyPhonic'
             'PhonicsClass'
           else
             lesson.type
           end

    { 'DailyActivity' => { 'Kindy' => 'row-start-3', 'Elementary' => 'row-start-5' },
      'Exercise' => { 'All Levels' => 'row-start-4' },
      'PhonicsClass' => { 'Kindy' => 'row-start-6', 'Land' => 'row-start-7', 'Sky' => 'row-start-8',
                          'Galaxy' => 'row-start-9' },
      'EnglishClass' => { 'Kindy' => 'row-start-10', 'Land' => 'row-start-11', 'Sky' => 'row-start-12',
                          'Galaxy' => 'row-start-13' },
      'StandShowSpeak' => { 'Land' => 'row-start-[12]', 'Sky' => 'row-start-[13]', 'Galaxy' => 'row-start-[14]' },
      'EveningClass' => { 'Keep Up' => 'row-start-[15]',
                          'Specialist' => 'row-start-[16]' } }[type][lesson.short_level]
  end
end
