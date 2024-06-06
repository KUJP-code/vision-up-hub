# frozen_string_literal: true

class KindyPhonic < Lesson
  include Listable, PdfUploadable

  ATTRIBUTES = %i[blending_words guide lesson_topic notes term unit vocab].freeze
  LISTABLE_ATTRIBUTES = %i[blending_words notes vocab].freeze

  enum level: { kindy: 1 }

  attr_accessor :lesson_topic, :term, :unit

  alias_attribute :blending_words, :example_sentences

  before_validation :set_topic, :ensure_kindy

  validates :blending_words, :vocab, presence: true
  with_options if: proc { |l| l.topic.nil? } do
    validates :lesson_topic, presence: true
    validates :term, inclusion: { in: (1..3).map(&:to_s) }
    validates :unit, inclusion: { in: (1..20).map(&:to_s) }
  end

  private

  def ensure_kindy
    self.level = :kindy
  end

  def set_topic
    self.topic = "Term #{term} Unit #{unit} - #{lesson_topic}"
  end
end
