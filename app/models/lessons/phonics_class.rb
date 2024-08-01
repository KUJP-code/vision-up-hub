# frozen_string_literal: true

class PhonicsClass < Lesson
  include Linkable, Listable, PdfImageValidatable, PhonicsClassPdf

  has_one_attached :pdf_image
  PDF_IMAGES = %i[pdf_image].freeze

  ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    instructions
    links
    materials
    notes
    pdf_image
  ].freeze

  LISTABLE_ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    instructions
    materials
    notes
  ].freeze

  validates :instructions, presence: true

  has_many :phonics_resources, dependent: :destroy
  accepts_nested_attributes_for :phonics_resources,
                                reject_if: :all_blank,
                                allow_destroy: true
  has_many :category_resources, through: :phonics_resources
end
