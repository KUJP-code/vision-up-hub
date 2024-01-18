# frozen_string_literal: true

class Lesson < ApplicationRecord
  validates :title, :summary, :category, :week, :day, presence: true
  validates :week, comparison: { greater_than: 0, less_than: 53 }

  enum category: {
    english_class: 0,
    phonics: 1,
    daily_activity: 2,
    exercise: 3
  }

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
