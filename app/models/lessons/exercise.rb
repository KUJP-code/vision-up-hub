# frozen_string_literal: true

class Exercise < Lesson
  include PdfUploadable

  ATTRIBUTES = %i[goal guide resources subtype].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze

  enum level: { all_levels: 0, kindy: 1, elementary: 2 }

  enum subtype: {
    aerobics: 0,
    control: 1,
    jumping: 2,
    throwing: 3
  }
end
