# frozen_string_literal: true

module TeacherLessonHelper
  def lvl_border(level)
    { 'Kindy' => 'border-kindy',
      'Land' => 'border-land',
      'Sky' => 'border-sky',
      'Galaxy' => 'border-galaxy' }[level]
  end

  def lvl_text(level)
    { 'Kindy' => 'text-kindy',
      'Land' => 'text-land',
      'Sky' => 'text-sky',
      'Galaxy' => 'text-galaxy' }[level]
  end
end
