# frozen_string_literal: true

class DailyActivity < Lesson
  before_validation :set_links, :set_steps

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

  def set_links
    pairs = links.split("\n")
    self.links = pairs.to_h { |pair| pair.split(':', 2) }
  end

  def set_steps
    self.steps = steps.split("\n")
  end
end
