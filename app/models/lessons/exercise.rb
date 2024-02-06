# frozen_string_literal: true

class Exercise < Lesson
  include ExercisePdf, Linkable

  attr_accessor :image
end
