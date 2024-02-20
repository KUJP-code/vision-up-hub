# frozen_string_literal: true

class SchoolClass < ApplicationRecord
  validates :name, presence: true

  belongs_to :school
  has_many :student_classes, dependent: :destroy
  has_many :students, through: :student_classes
end
