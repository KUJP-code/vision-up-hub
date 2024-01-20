# frozen_string_literal: true

class Lesson < ApplicationRecord
  TYPES = %w[DailyActivity EnglishClass Exercise Phonics].freeze

  validates :title, :summary, :type, :week, :day, presence: true
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

  belongs_to :course
end
