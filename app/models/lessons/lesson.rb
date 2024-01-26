# frozen_string_literal: true

class Lesson < ApplicationRecord
  require 'prawn'

  TYPES = %w[DailyActivity EnglishClass Exercise Phonics].freeze

  validates :level, :title, :type, :summary, presence: true
  validates :type, inclusion: { in: TYPES }

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

  def day(course)
    course_lessons.find_by(course_id: course.id).day.capitalize
  end

  def week(course)
    number = course_lessons.find_by(course_id: course.id).week
    "Week #{number}"
  end
end
