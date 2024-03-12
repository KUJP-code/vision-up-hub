# frozen_string_literal: true

class Exercise < Lesson
  include ExercisePdf, Linkable, Listable, PdfImageable

  ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    guide_image
    intro
    instructions
    large_groups
    links
    materials
    notes
    outro
    subtype
  ].freeze

  LISTABLE_ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    intro
    instructions
    large_groups
    materials
    notes
    outro
  ].freeze

  PDF_IMAGEABLE_ATTRIBUTES = %i[guide_image].freeze

  enum subtype: {
    aerobics: 0,
    control: 1,
    jumping: 2,
    throwing: 3
  }

  validates :intro, :instructions, presence: true

  has_one_attached :guide_image
end
