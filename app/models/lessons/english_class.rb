# frozen_string_literal: true

class EnglishClass < Lesson
  include Listable, PdfUploadable, Topicable

  ATTRIBUTES = %i[example_sentences guide lesson_topic
                  notes term unit vocab].freeze

  LISTABLE_ATTRIBUTES = %i[example_sentences notes vocab].freeze

  validates :example_sentences, :vocab, presence: true
end
