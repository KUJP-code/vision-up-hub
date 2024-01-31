# frozen_string_literal: true

class SchoolManager < User
  VISIBLE_TYPES = %w[SchoolManager Teacher].freeze

  has_many :managements, dependent: :destroy
  has_many :schools, through: :managements

  def teachers
    Teacher.where(school_id: schools.ids)
  end
end
