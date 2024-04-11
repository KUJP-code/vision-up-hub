# frozen_string_literal: true

class PhonicsClass < Lesson
  include PhonicsClassPdf, Linkable, Listable

  ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    instructions
    links
    materials
    notes
  ].freeze

  LISTABLE_ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    instructions
    materials
    notes
  ].freeze

  validates :instructions, presence: true

  def icon_filename
    'phonics_class.svg'
  end
end
