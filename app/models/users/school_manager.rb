# frozen_string_literal: true

class SchoolManager < User
  has_many :managements, dependent: :destroy
  has_many :schools, through: :managements

  def teachers
    Teacher.where(school_id: schools.ids)
  end
end
