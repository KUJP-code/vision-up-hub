# frozen_string_literal: true

class Organisation < ApplicationRecord
  validates :email, :name, :phone, presence: true
  validates :email, :phone, uniqueness: true

  has_many :schools, dependent: :destroy
  has_many :users, dependent: :destroy

  def students_count
    schools.sum(:students_count)
  end
end
