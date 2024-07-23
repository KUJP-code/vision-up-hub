# frozen_string_literal: true

class SchoolClass < ApplicationRecord
  validates :name, presence: true

  belongs_to :school
  delegate :organisation, to: :school
  delegate :organisation_id, to: :school

  has_many :student_classes, dependent: :destroy,
                             foreign_key: :class_id,
                             inverse_of: :school_class
  accepts_nested_attributes_for :student_classes
  has_many :students, through: :student_classes

  has_many :class_teachers, dependent: :destroy,
                            foreign_key: :class_id,
                            inverse_of: :school_class
  accepts_nested_attributes_for :class_teachers,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :teachers, through: :class_teachers
end
