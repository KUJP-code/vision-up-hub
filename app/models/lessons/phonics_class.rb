# frozen_string_literal: true

class PhonicsClass < Lesson
  include PdfImageable, PhonicsClassPdf, Linkable, Listable

  ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    instructions
    links
    materials
    notes
    pdf_image
  ].freeze

  LISTABLE_ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    instructions
    materials
    notes
  ].freeze

  validates :instructions, presence: true
end
