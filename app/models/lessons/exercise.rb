# frozen_string_literal: true

class Exercise < Lesson
  include PdfUploadable

  ATTRIBUTES = %i[goal guide resources subtype].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze

  enum subtype: {
    aerobics: 0,
    control: 1,
    jumping: 2,
    throwing: 3
  }
end
