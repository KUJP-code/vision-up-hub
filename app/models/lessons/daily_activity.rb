# frozen_string_literal: true

class DailyActivity < Lesson
  include DailyActivityPdf, Linkable, Listable

  ATTRIBUTES = %i[
    extra_fun
    instructions
    intro
    large_groups
    links
    materials
    notes
    subtype
  ].freeze

  LISTABLE_ATTRIBUTES = %i[
    extra_fun
    instructions
    intro
    large_groups
    materials
    notes
  ].freeze

  validates :intro, :instructions, :subtype, presence: true

  enum level: {
    kindy: 0,
    elementary: 1
  }

  enum subtype: {
    discovery: 0,
    brain_training: 1,
    dance: 2,
    games: 3,
    imagination: 4,
    life_skills: 5,
    drawing: 6,
    arts_and_crafts: 7,
    origami: 8,
    motor_skills: 9,
    coloring: 10
  }

  has_many_attached :instructions_images
end
