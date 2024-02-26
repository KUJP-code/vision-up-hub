# frozen_string_literal: true

class Organisation < ApplicationRecord
  validates :email, :name, :phone, presence: true
  validates :email, :name, :phone, uniqueness: true

  has_many :schools, dependent: :destroy
  has_many :students, through: :schools
  has_many :classes, through: :schools
  has_many :users, dependent: :destroy

  def students_count
    schools.sum(:students_count)
  end
end
