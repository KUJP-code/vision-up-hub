# frozen_string_literal: true

class Course < ApplicationRecord
  before_validation :set_root_path

  validates :name, :root_path, presence: true

  has_many :course_lessons, dependent: :destroy
  has_many :lessons, through: :course_lessons

  private

  def set_root_path
    self.root_path = name.tr(' ', '').underscore
  end
end
