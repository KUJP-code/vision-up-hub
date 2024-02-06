# frozen_string_literal: true

class EnglishClass < Lesson
  include Listable

  LISTABLE_ATTRIBUTES = %i[example_sentences notes vocab].freeze

  attr_accessor :lesson_topic, :term, :unit

  before_validation :listify_attributes, :set_topic

  validates :example_sentences, :vocab, presence: true

  private

  # Currently we're just uploading PDFs for English classes
  def attach_guide; end

  def set_topic
    self.topic = "Term #{term} Unit #{unit} - #{lesson_topic}"
  end
end
