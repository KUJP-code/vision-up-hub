# frozen_string_literal: true

class DailyActivity < Lesson
  include DailyActivityPdf, Linkable, Listable

  before_validation :listify_steps

  enum subtype: {
    discovery: 0,
    brain_training: 1,
    dance: 2,
    games: 3,
    imagination: 4,
    life_skills: 5,
    drawing: 6
  }

  private

  def listify_steps
    self.steps = listify(steps, :steps)
  end
end
