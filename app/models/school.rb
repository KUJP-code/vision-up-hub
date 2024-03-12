# frozen_string_literal: true

class School < ApplicationRecord
  validates :name, presence: true

  belongs_to :organisation
  has_many :classes, dependent: :destroy,
                     class_name: 'SchoolClass'
  has_many :managements, dependent: :destroy
  accepts_nested_attributes_for :managements,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :school_managers, through: :managements
  has_many :students, dependent: :restrict_with_error
  has_many :test_results, through: :students
  has_many :school_teachers, dependent: :destroy
  has_many :teachers, through: :school_teachers
end
