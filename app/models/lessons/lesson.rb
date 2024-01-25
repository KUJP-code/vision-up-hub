# frozen_string_literal: true

class Lesson < ApplicationRecord
  require 'prawn'

  TYPES = %w[DailyActivity EnglishClass Exercise Phonics].freeze

  validates :day, :level, :title, :type, :summary, :week, presence: true
  validates :week, comparison: { greater_than: 0, less_than: 53 }
  validates :type, inclusion: { in: TYPES }

  enum day: {
    sunday: 1,
    monday: 2,
    tuesday: 3,
    wednesday: 4,
    thursday: 5,
    friday: 6,
    saturday: 7
  }

  enum level: {
    kindy: 0,
    land_one: 1,
    land_two: 2,
    sky_one: 3,
    sky_two: 4,
    galaxy_one: 5,
    galaxy_two: 6,
    keep_up: 7,
    specialist: 8
  }

  has_one_attached :guide do |g|
    g.variant :thumb, resize_to_limit: [400, 400], convert: :avif, preprocessed: true
  end

  has_many :course_lessons, dependent: :destroy
  accepts_nested_attributes_for :course_lessons, allow_destroy: true
  has_many :courses, through: :course_lessons

  private

  def underscored_title
    title.parameterize(separator: '_')
  end
end
