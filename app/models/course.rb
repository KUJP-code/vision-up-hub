# frozen_string_literal: true

class Course < ApplicationRecord
  before_validation :set_root_path

  validates :name, :root_path, presence: true

  private

  def set_root_path
    self.root_path = "/#{name.parameterize}"
  end
end
