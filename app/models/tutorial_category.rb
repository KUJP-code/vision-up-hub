# frozen_string_literal: true

class TutorialCategory < ApplicationRecord
  has_many :pdf_tutorials, dependent: :restrict_with_error
  has_many :faq_tutorials, dependent: :restrict_with_error
  has_many :video_tutorials, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
