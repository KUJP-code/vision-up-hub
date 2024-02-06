# frozen_string_literal: true

class EnglishClass < Lesson
  include Listable

  LISTABLE_ATTRIBUTES = %i[example_sentences notes vocab].freeze

  attr_accessor :lesson_topic, :term, :unit

  before_validation :listify_attributes, :set_topic

  validates :example_sentences, :lesson_topic, :vocab, presence: true
  validates :term, inclusion: { in: (1..3).map(&:to_s) }
  validates :unit, inclusion: { in: (1..20).map(&:to_s) }

  def form_topic
    return '' if topic.nil?

    topic.scan(/(?<=- ).+/).first
  end

  def form_term
    return '' if topic.nil?

    topic.scan(/\d+/).first
  end

  def form_unit
    return '' if topic.nil?

    topic.scan(/\d+/).last
  end

  private

  def set_topic
    self.topic = "Term #{term} Unit #{unit} - #{lesson_topic}"
  end
end
