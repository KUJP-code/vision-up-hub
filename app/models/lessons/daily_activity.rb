# frozen_string_literal: true

class DailyActivity < Lesson
  include DailyActivityPdf, Linkable, Listable

  LISTABLE_ATTRIBUTES = %i[
    extra_fun
    intro
    instructions
    large_groups
    materials
    notes
  ].freeze

  validates :intro, :instructions, :subtype, presence: true

  enum subtype: {
    discovery: 0,
    brain_training: 1,
    dance: 2,
    games: 3,
    imagination: 4,
    life_skills: 5,
    drawing: 6
  }

  has_many_attached :instructions_images
end
