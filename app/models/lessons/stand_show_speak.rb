# frozen_string_literal: true

class StandShowSpeak < Lesson
  include PdfUploadable

  ATTRIBUTES = %i[guide].freeze
  LISTABLE_ATTRIBUTES = %i[].freeze
end
