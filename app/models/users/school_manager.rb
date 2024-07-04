# frozen_string_literal: true

class SchoolManager < User
  include Courseable, IpLockable

  VISIBLE_TYPES = %w[Parent Teacher].freeze

  has_many :managements, dependent: :destroy
  accepts_nested_attributes_for :managements,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :schools, through: :managements
  has_many :classes, through: :schools,
                     class_name: 'SchoolClass'
  has_many :students, through: :schools
  has_many :parents, through: :students
  has_many :test_results, through: :students
  has_many :teachers, through: :schools
end
