# frozen_string_literal: true

module TeacherLessonHelper
  def lvl_border(level)
    { 'Kindy' => 'border-kindy', 'Land' => 'border-land',
      'Sky' => 'border-sky', 'Galaxy' => 'border-galaxy',
      'Keep Up' => 'border-keep-up',
      'Specialist' => 'border-specialist' }[level]
  end

  def lvl_text(level)
    { 'Kindy' => 'text-kindy', 'Land' => 'text-land',
      'Sky' => 'text-sky', 'Galaxy' => 'text-galaxy',
      'Keep Up' => 'text-keep-up', 'Specialist' => 'text-specialist' }[level]
  end
end
