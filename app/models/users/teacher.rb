# frozen_string_literal: true

class Teacher < User
  include IpLockable, LessonConsumable

  CSV_HEADERS = %w[name email password].freeze
  VISIBLE_TYPES = %w[].freeze

  has_many :class_teachers, dependent: :destroy
  accepts_nested_attributes_for :class_teachers
  has_many :classes, through: :class_teachers,
                     source: :school_class
  has_many :students, through: :classes
  has_many :test_results, through: :students
  has_many :school_teachers, dependent: :destroy
  accepts_nested_attributes_for :school_teachers
  has_many :schools, through: :school_teachers
end
