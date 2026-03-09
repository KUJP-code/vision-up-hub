# frozen_string_literal: true

class EnglishClass < Lesson
  include Listable, PdfUploadable, Topicable

  ATTRIBUTES = %i[example_sentences guide lesson_topic
                  notes term unit vocab
                  homework_sheet homework_answers].freeze

  LISTABLE_ATTRIBUTES = %i[example_sentences notes vocab].freeze

  has_one_attached :homework_sheet
  has_one_attached :homework_answers
end
