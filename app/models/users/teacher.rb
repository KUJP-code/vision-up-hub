# frozen_string_literal: true

class Teacher < User
  VISIBLE_TYPES = %w[].freeze

  has_many :class_teachers, dependent: :destroy
  accepts_nested_attributes_for :class_teachers
  has_many :classes, through: :class_teachers,
                     source: :school_class
  has_many :students, through: :classes
  belongs_to :organisation
  delegate :plan, to: :organisation
  delegate :course, to: :plan
  delegate :lessons, to: :course
  has_many :school_teachers, dependent: :destroy
  accepts_nested_attributes_for :school_teachers
  has_many :schools, through: :school_teachers

  def course_week(date)
    (((date - plan.start).to_i + 1) / 7.0).ceil
  end

  def day_lessons(date)
    return Lesson.none if plan.nil? || date > plan.finish_date

    day = date.strftime('%A').downcase
    week = course_week(date)
    lessons.where(course_lessons: { day:, week: })
  end
end
