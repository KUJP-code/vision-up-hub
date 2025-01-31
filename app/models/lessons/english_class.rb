# frozen_string_literal: true

class EnglishClass < Lesson
  include Listable, PdfUploadable, Topicable

  ATTRIBUTES = %i[example_sentences guide lesson_topic
                  notes term unit vocab].freeze

  LISTABLE_ATTRIBUTES = %i[example_sentences notes vocab].freeze

  validates :example_sentences, :vocab, presence: true

  has_many :homework_resources, dependent: :destroy
  accepts_nested_attributes_for :homework_resources,
                                reject_if: :all_blank,
                                allow_destroy: true
  has_many :category_resources, through: :homework_resources
end
