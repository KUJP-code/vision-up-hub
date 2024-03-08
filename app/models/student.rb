# frozen_string_literal: true

class Student < ApplicationRecord
  include Levelable

  validates :level, :name, presence: true
  encrypts :name

  belongs_to :school, counter_cache: true
  delegate :organisation_id, to: :school
  has_many :student_classes, dependent: :destroy
  accepts_nested_attributes_for :student_classes
  has_many :classes, through: :student_classes,
                     source: :school_class
end
