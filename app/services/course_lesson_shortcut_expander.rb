# frozen_string_literal: true

class CourseLessonShortcutExpander
  def initialize(course_lesson_attributes:)
    @course_lesson_attributes = course_lesson_attributes
  end

  def call
    course_lesson_attributes.to_unsafe_h.each_value
                             .flat_map { |attrs| expand_attribute(attrs) }
                             .each_with_index
                             .to_h { |attrs, index| [index.to_s, attrs] }
  end

  private

  attr_reader :course_lesson_attributes

  def expand_attribute(attrs)
    attrs = attrs.to_h.stringify_keys
    days = CourseLesson.expand_day_selection(attrs['day'])
    return [attrs] unless days.many?

    days.map.with_index do |day, index|
      index.zero? ? attrs.merge('day' => day) : attrs.except('id').merge('day' => day)
    end
  end
end
