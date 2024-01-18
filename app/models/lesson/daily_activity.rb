# frozen_string_literal: true

class Lesson::DailyActivity < Lesson
  enum subcategory: {
    discovery: 0,
    brain_training: 1,
    dance: 2,
    games: 3,
    imagination: 4,
    life_skills: 5,
    drawing: 6
  }
end
