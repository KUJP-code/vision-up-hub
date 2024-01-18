# frozen_string_literal: true

class Course < ApplicationRecord
  before_validation :set_root_path

  validates :name, :root_path, presence: true

  has_many :lessons, dependent: :destroy

  private

  def set_root_path
    self.root_path = name.parameterize
  end
end
