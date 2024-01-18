# frozen_string_literal: true

class Lesson < ApplicationRecord
  validates :title, :summary, :category, :week, :day, presence: true
  validates :week, comparison: { greater_than: 0, less_than: 53 }
  validates :day, inclusion: { in: 1..7 }

  enum category: {
    english_class: 0,
    phonics: 1,
    daily_activity: 2,
    exercise: 3
  }

  belongs_to :course
end
