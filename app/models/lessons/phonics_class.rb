# frozen_string_literal: true

class PhonicsClass < Lesson
  include PhonicsClassPdf, Linkable, Listable

  LISTABLE_ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    instructions
    materials
    notes
  ].freeze

  validates :instructions, presence: true
end
