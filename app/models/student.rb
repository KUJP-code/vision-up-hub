# frozen_string_literal: true

class Student < ApplicationRecord
  include Levelable

  validates :name, presence: true
  encrypts :name

  belongs_to :school
  has_many :student_classes, dependent: :destroy
  has_many :classes, through: :student_classes
end
