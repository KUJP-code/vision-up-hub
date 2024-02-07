# frozen_string_literal: true

class PhonicsClass < Lesson
  include PhonicsClassPdf, Linkable, Listable

  validates :instructions, presence: true

  LISTABLE_ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    instructions
    materials
    notes
  ].freeze
end
