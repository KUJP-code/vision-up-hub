# frozen_string_literal: true

class Organisation < ApplicationRecord
  include Courseable

  validates :email, :name, :phone, presence: true
  validates :email, :name, :phone, uniqueness: true

  has_many :schools, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :classes, through: :schools
  has_many :plans, dependent: :destroy
  has_many :courses, through: :plans
  has_many :course_lessons, through: :courses
  has_many :lessons, through: :courses
  has_many :users, dependent: :destroy
  has_many :support_requests, through: :users
  has_many :teachers, dependent: :destroy
  has_many :organisation_lessons, dependent: :destroy
  has_many :organisation_tutorial_categories, dependent: :destroy
  has_many :tutorial_categories, through: :organisation_tutorial_categories
  has_many :seasonal_lessons, through: :organisation_lessons, source: :lesson

  def students_count
    schools.sum(:students_count)
  end
end
