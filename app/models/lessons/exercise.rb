# frozen_string_literal: true

class Exercise < Lesson
  include ExercisePdf, Linkable

  has_one_attached :image
end
