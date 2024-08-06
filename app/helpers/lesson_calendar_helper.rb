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

    { 'DailyActivity' => { 'Kindy' => 'row-start-2', 'Elementary' => 'row-start-4' },
      'Exercise' => { 'All Levels' => 'row-start-3' },
      'PhonicsClass' => { 'Kindy' => 'row-start-5', 'Land' => 'row-start-6', 'Sky' => 'row-start-7',
                          'Galaxy' => 'row-start-8' },
      'EnglishClass' => { 'Kindy' => 'row-start-9', 'Land' => 'row-start-10', 'Sky' => 'row-start-11',
                          'Galaxy' => 'row-start-12' },
      'StandShowSpeak' => { 'Land' => 'row-start-[13]', 'Sky' => 'row-start-[14]', 'Galaxy' => 'row-start-[15]' },
      'EveningClass' => { 'Keep Up' => 'row-start-[16]',
                          'Specialist' => 'row-start-[17]' } }[type][lesson.short_level]
  end
end
