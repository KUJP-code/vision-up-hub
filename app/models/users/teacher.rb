# frozen_string_literal: true

class Teacher < User
  VISIBLE_TYPES = %w[].freeze

  belongs_to :organisation
  has_many :school_teachers, dependent: :destroy
  accepts_nested_attributes_for :school_teachers
  has_many :schools, through: :school_teachers
end
