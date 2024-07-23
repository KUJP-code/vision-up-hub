# frozen_string_literal: true

class KindyPhonic < Lesson
  include Listable, PdfUploadable, Topicable

  ATTRIBUTES = %i[blending_words guide lesson_topic notes
                  term unit vocab].freeze
  LISTABLE_ATTRIBUTES = %i[blending_words notes vocab].freeze

  enum level: { kindy: 1 }

  alias_attribute :blending_words, :example_sentences
  before_validation :ensure_kindy

  validates :blending_words, :vocab, presence: true

  private

  def ensure_kindy
    self.level = :kindy
  end
end
