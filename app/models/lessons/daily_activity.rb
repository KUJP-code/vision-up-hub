# frozen_string_literal: true

class DailyActivity < Lesson
  include DailyActivityPdf, Linkable, Listable, PdfImageable

  store_accessor :lang_goals, :land, :sky, :galaxy, suffix: true

  ATTRIBUTES = %i[
    subtype
    pdf_image
    warning
    land_lang_goals
    sky_lang_goals
    galaxy_lang_goals
    materials
    intro
    interesting_fact
    instructions
    large_groups
    outro
    notes
    links
  ].freeze

  LISTABLE_ATTRIBUTES = %i[
    land_lang_goals
    sky_lang_goals
    galaxy_lang_goals
    materials
    intro
    instructions
    large_groups
    outro
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
end
