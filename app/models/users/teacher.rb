# frozen_string_literal: true

class Teacher < User
  VISIBLE_TYPES = %w[].freeze

  has_many :class_teachers, dependent: :destroy
  accepts_nested_attributes_for :class_teachers
  has_many :classes, through: :class_teachers,
                     source: :school_class
  has_many :students, through: :classes
  belongs_to :organisation
  has_many :school_teachers, dependent: :destroy
  accepts_nested_attributes_for :school_teachers
  has_many :schools, through: :school_teachers
end
